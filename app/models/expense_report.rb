#
# This model is used to encapsulate the queries involved in the expenses report
# using the ActiveRecord query interface. It's a read-only model offering a more
# convenient way of reading information from the request_expenses table, so
# it's not intended for creating or updating records. Please, use the RequestExpense
# model for that purpose.
# @see RequestExpense
#
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

  # Main scope for using the whole model. Takes cares of all the grouping,
  # conditions and selections needed for a given amount field and a given
  # grouping option. Best examples of use can be found in reports_controller.
  #
  # @param [#to_sym] type Type of expense to summarize: :estimated, :approved,
  #                       :total or :authorized
  # @param [#to_sym] g  Grouping option. For a list of all the available
  #                     options, use ExpenseReport.groups
  # @see .groups                       
  scope :by, lambda {|type, g|
    currency = RequestExpense.currency_field_for(type.to_sym)
    r = joins(:request => [{:user => :profile}, :event])
    r = r.joins("LEFT JOIN reimbursements ON reimbursements.request_id = requests.id")
    # FIXME:
    # DISTINCT is used to force kaminari to use the "right" length calculation,
    # which is quite inefficient. It would be better to find a way to pass the
    # total_count to kaminari
    r = r.select("DISTINCT sum(#{type}_amount) AS sum_amount, #{currency} AS sum_currency, #{@by[g.to_sym].map{|f| "#{f[:sql]} AS #{f[:field]}"}.join(', ')}")
    r = r.where("#{type}_amount IS NOT NULL")
    r = r.group("#{currency}, #{@by[g.to_sym].map{|f| f[:sql]}.join(', ')}")
  }

  # Scope for filtering
  scope :event_start_lte, lambda {|date|
    where(["events.start_date <= ?", date])
  }

  # Scope for filtering
  scope :event_start_gte, lambda {|date|
    where(["events.start_date >= ?", date])
  }

  # Scope for filtering
  scope :event_eq, lambda {|event_id|
    where("events.id" => event_id)
  }

  # Scope for filtering
  scope :event_name_contains, lambda {|name|
    where(["lower(events.name) like ?", "%#{name}%"])
  }

  # Scope for filtering
  scope :event_country_code_eq, lambda {|country|
    where("events.country_code" => country)
  }

  # Scope for filtering
  scope :user_name_contains, lambda {|name|
    where(["lower(user_profiles.full_name) like ? or lower(users.nickname) like ?"] + ["%#{name}%"]*2)
  }

  # Scope for filtering
  scope :user_country_code_eq, lambda {|country|
    where("user_profiles.country_code" => country)
  }

  # Scope for filtering
  scope :request_state_eq, lambda {|state|
    where("requests.state" => state.to_s)
  }

  # Scope for filtering
  scope :reimbursement_state_eq, lambda {|state|
    where("reimbursements.state" => state.to_s)
  }

  # Ordered list of field names for a given call to the 'by' scope
  #
  # @param [#to_sym] group The grouping option used when invoking the scope
  # @return [array] The names of the resulting fields (as an array of symbols)
  def self.fields_for(group)
    @by[group.to_sym].select {|f| !f[:hidden]}.map {|i| i[:field]} + [ :sum_amount, :sum_currency ]
  end

  # Available group options for calling the 'by' scope
  #
  # @return [array] An array with the available grouping criterias (as symbols)
  def self.groups
    @by.keys
  end

  # Casted value of a given attribute.
  #
  # Needed because ActiveRecord always return the attributes as strings when
  # ActiveRelation#select is used. This method casts the attributes back to its
  # correct type. Intended to be used on records resulting from a call to the
  # 'by' scope.
  #
  # @param [#to_sym] name attribute name
  # @return [Object] value of the attribute
  def value_for(name)
    # At this point creating a more generic solution is not worthy, we simply
    # check explicitly for one of the three special cases
    if name.to_sym == :sum_amount
      # to_f.to_s to ensure that it has a decimal part (with any db engine)
      BigDecimal.new(sum_amount.to_f.to_s || "0.0")
    elsif [:event_start_date, :event_end_date].include? name.to_sym
      d = send(name)
      d.blank? ? nil : Date.parse(d)
    else
      send(name)
    end
  end
end
