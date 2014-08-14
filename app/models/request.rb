#
# Request from a user to get help from the TSP for a given event
#
class Request < ActiveRecord::Base
  include HasState

  # The event associated to the state machine
  belongs_to :event
  # Comments used to discuss decisions (private) or communicate with the requester (public)
  has_many :comments, :as => :machine, :dependent => :destroy
  # Estimated expenses, including (for every expense) the estimated amount,
  # the amount of the help that TSP approves, the amount finally expended and
  # the amount that is going to be reimbursed
  has_many :expenses, :class_name => "RequestExpense", :inverse_of => :request, :dependent => :destroy
  # Every accepted request is followed by a reimbursement process
  has_one :reimbursement, :inverse_of => :request, :dependent => :restrict_with_exception

  accepts_nested_attributes_for :expenses, :reject_if => :all_blank, :allow_destroy => true

  validates :event, :presence => true
  validates_associated :expenses
  validate :only_one_active_request, :if => :active?
  validate :dont_exceed_budget, :if => :approved?
  validate :has_no_expenses, :if => :submitted?

  scope :in_conflict_with, lambda { |req|
    others = active.where(user_id: req.user_id, event_id: req.event_id)
    others = others.where(["id <> ?", req.id]) if req.id
    others
  }

  auditable


  # @see HasState.responsible_roles
  self.responsible_roles = [:tsp, :assistant]

  # @see HasState.assign_state
  assign_state :incomplete, :to => :requester
  assign_state :submitted, :to => :tsp
  assign_state :approved, :to => :requester


  # Checks if user role can cancel the request
  #
  # @param [Role] user role to be checked
  # @return [Boolean] true if role can cancel
  def cancel_role?(role)
    [1,2,3].include?(role.id)
  end



  # Checks whether a tsp user should be allowed to cancel
  #
  # tsp users cannot cancel a request if it has already been accepted by the
  # requester
  #
  # @return [Boolean] true if allowed
  def cancelable_by_tsp?
    can_cancel? and not accepted?
  end

  # Checks whether can have a transition to 'canceled' state
  #
  # Overrides the HasState.can_cancel?, preventing cancelation of requests that
  # already have an active reimbursement
  # @see HasState.can_cancel?
  #
  # return [Boolean] true if #cancel can be called
  def can_cancel?
    not canceled? and (reimbursement.nil? or not reimbursement.active?)
  end


  # Checks whether the request is ready for reimbursement
  #
  # @return [Boolean] true if all conditions are met
  def can_have_reimbursement?
    accepted? && (!reimbursement.nil? || event.accepting_reimbursements?)
  end

  # Checks whether a request is ready for reimbursement but the process have not
  # yet started
  #
  # @return [Boolean] if there is no associated reimbursement
  def lacks_reimbursement?
    can_have_reimbursement? and (reimbursement.nil? || reimbursement.new_record?)
  end

  # Check wheter the visa_letter attribute can be used
  #
  # @return [Boolean] true if the requester can ask for visa letter
  def visa_letter_allowed?
    event.try(:visa_letters) == true
  end

  # Summarizes one of the xxx_amount attributes from the request's expenses grouping
  # it by currency.
  #
  # A value of nil for the amount is ignored (the currency will not be present
  # in the result if all related amounts are nil), but zeros are counted (so the
  # currency will be present even if all the corresponding amounts are 0.0).
  #
  # All the calculations are done in pure ruby (no SQL involved), so be sure to
  # use includes(:expenses) when using it through an ActiveRecord::Relation
  #
  # @param [Symbol] attr Attribute to summarize, can be :estimated, :approved,
  #   :total or :authorized
  # @return [ActiveSupport::OrderedHash] with currencies as keys and sums as value,
  #     ordered by currencies' alphabetic order
  def expenses_sum(attr = :total)
    grouped = expenses.group_by(&:"#{attr}_currency")
    nonils = grouped.each {|k,v| v.delete_if {|i| i.send(:"#{attr}_amount").nil?}}.delete_if {|k,v| v.empty?}
    unordered = nonils.map {|k,v| [k, v.sum(&:"#{attr}_amount")] }
    ActiveSupport::OrderedHash[ unordered.sort_by(&:first) ]
  end

  def self.expenses_sum(attr = :total, requests)
    amount_field = :"#{attr}_amount"
    if requests.kind_of?(ActiveRecord::Relation)
      r_ids = requests.reorder("").pluck("requests.id")
    else
      r_ids = requests.map {|i| i.kind_of?(Integer) ? i : i.id }
    end
    RequestExpense.by_attr_for_requests(attr, r_ids).sum(amount_field)
  end

  protected

  def only_one_active_request
    if Request.in_conflict_with(self).count > 0
      errors.add(:event_id, :only_one_active)
    end
  end

  # Validates that the approved amount doesn't exceed the total of the budgets
  # associated to the event.
  def dont_exceed_budget
    if TravelSupport::Config.setting :budget_limits
      budget = event.budget
      currency = budget ? budget.currency : nil

      # With the current implementation, it should be only one approved currency
      if currency.nil? || expenses.any? {|e| e.approved_currency != currency }
        errors.add(:expenses, :no_budget_found)
        return
      end

      # Expenses for other requests using the same budget
      more_expenses = RequestExpense.includes(:request => [:event, :reimbursement])
      more_expenses = more_expenses.where("events.budget_id" => budget.id)
      more_expenses = more_expenses.where("request_expenses.approved_currency" => currency)
      more_expenses = more_expenses.where(["requests.id <> ?", id])
      more_expenses = more_expenses.where(["requests.state in (?)", %w(approved accepted)])
      # If the request have a canceled reimbursement, it means that the money is in fact available
      more_expenses = more_expenses.where(["reimbursements.id is null or reimbursements.state <> ?", "canceled"])

      total = more_expenses.where(["authorized_amount is null"]).sum(:approved_amount) +
              more_expenses.where(["authorized_amount is not null"]).sum(:authorized_amount) +
              expenses.to_a.sum(&:approved_amount)
      errors.add(:expenses, :budget_exceeded) if total > budget.amount
    end
  end

  # Validates that the request doesn't have empty expenses for a submission
  def has_no_expenses
    if expenses.empty?
      errors.add(:state, :empty_expenses_for_submission)
    end
  end
end
