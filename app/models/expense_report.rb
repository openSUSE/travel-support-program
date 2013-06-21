class ExpenseReport < ActiveRecord::Base
  self.table_name = "request_expenses"

  belongs_to :request
  delegate :reimbursement, :to => :request, :prefix => false
  delegate :user, :to => :request, :prefix => false
  delegate :event, :to => :request, :prefix => false

  @by = {
    :event => [
          { :field => :event_id, :sql => "event_id", :hidden => true },
          { :field => :event_name, :sql => "events.name" },
          { :field => :event_country, :sql => "events.country_code" },
          { :field => :event_start_date, :sql => "events.start_date" },
          { :field => :event_end_date, :sql => "events.end_date" } ],

    :event_country => [ {:field => :event_country, :sql => "events.country_code"} ],

    :user => [
          { :field => :user_id, :sql => "requests.user_id", :hidden => true },
          { :field => :user_nickname, :sql => "users.nickname" },
          { :field => :user_fullname, :sql => "user_profiles.full_name" },
          { :field => :user_country, :sql => "user_profiles.country_code" } ],

    :user_country => [ {:field => :user_country, :sql => "user_profiles.country_code"} ],

    :subject => [ { :field => :subject, :sql => "request_expenses.subject" } ],

    :request => [
          { :field => :request_id, :sql => "requests.id" },
          { :field => :request_state, :sql => "requests.state" },
          { :field => :reimbursement_id, :sql => "reimbursements.id" },
          { :field => :reimbursement_state, :sql => "reimbursements.state" },
          { :field => :user_id, :sql => "requests.user_id", :hidden => true },
          { :field => :user_nickname, :sql => "users.nickname" },
          { :field => :user_fullname, :sql => "user_profiles.full_name" },
          { :field => :event_id, :sql => "event_id", :hidden => true },
          { :field => :event_name, :sql => "events.name" } ],

    :expense => [
          { :field => :expense_id, :sql => "request_expenses.id", :hidden => true}, 
          { :field => :request_id, :sql => "requests.id" },
          { :field => :request_state, :sql => "requests.state" },
          { :field => :reimbursement_id, :sql => "reimbursements.id" },
          { :field => :reimbursement_state, :sql => "reimbursements.state" },
          { :field => :user_id, :sql => "requests.user_id", :hidden => true },
          { :field => :user_nickname, :sql => "users.nickname" },
          { :field => :user_fullname, :sql => "user_profiles.full_name" },
          { :field => :event_id, :sql => "event_id", :hidden => true },
          { :field => :event_name, :sql => "events.name" },
          { :field => :subject, :sql => "request_expenses.subject" } ] }

  scope :by, lambda {|type, g|
    currency = RequestExpense.currency_field_for(type.to_sym)
    r = joins(:request => [{:user => :profile}, :event])
    r = r.joins("LEFT JOIN reimbursements ON reimbursements.request_id = requests.id")
    # FIXME:
    # DISTINCT is used to force kaminari to use the "right" length calculation,
    # which is quite inefficient. It would be better to find a way to pass the
    # total_count to kaminari
    r = r.select("DISTINCT sum(#{type}_amount) AS sum_amount, #{currency} AS sum_currency, #{@by[g.to_sym].map{|f| "#{f[:sql]} AS #{f[:field]}"}.join(', ')}")
    r = r.group("#{currency}, #{@by[g.to_sym].map{|f| f[:sql]}.join(', ')}")
  }

  scope :event_start_lte, lambda {|date|
    where(["events.start_date <= ?", date])
  }

  scope :event_start_gte, lambda {|date|
    where(["events.start_date >= ?", date])
  }

  scope :event_eq, lambda {|event_id|
    where("events.id" => event_id)
  }

  scope :event_name_contains, lambda {|name|
    where(["lower(events.name) like ?", "%#{name}%"])
  }

  scope :event_country_code_eq, lambda {|country|
    where("events.country_code" => country)
  }

  scope :user_name_contains, lambda {|name|
    where(["lower(user_profiles.full_name) like ? or lower(users.nickname) like ?"] + ["%#{name}%"]*2)
  }

  scope :user_country_code_eq, lambda {|country|
    where("user_profiles.country_code" => country)
  }

  scope :request_state_eq, lambda {|state|
    where("requests.state" => state.to_s)
  }

  scope :reimbursement_state_eq, lambda {|state|
    where("reimbursements.state" => state.to_s)
  }

  def self.fields_for(group)
    @by[group.to_sym].select {|f| !f[:hidden]}.map {|i| i[:field]} + [ :sum_amount, :sum_currency ]
  end

  def self.groups
    @by.keys
  end

  def value_for(name)
    # At this point creating a more generic solution is not worthy, we simply
    # check explicitly for one of the three special cases
    if name.to_sym == :sum_amount
      BigDecimal.new(sum_amount)
    elsif [:event_start_date, :event_end_date].include? name.to_sym
      Date.parse(send(name))
    else
      send(name)
    end
  end
end
