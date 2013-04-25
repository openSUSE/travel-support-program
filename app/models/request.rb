#
# Request from a user to get help from the TSP for a given event
#
class Request < ActiveRecord::Base
  include TravelSupportProgram::HasState
  # The event the requester wants to attend.
  belongs_to :event
  # Estimated expenses, including (for every expense) the estimated amount,
  # the amount of the help that TSP approves, the amount finally expended and
  # the amount that is going to be reimbursed
  has_many :expenses, :class_name => "RequestExpense", :inverse_of => :request
  # Every accepted request is followed by a reimbursement process
  has_one :reimbursement, :inverse_of => :request

  accepts_nested_attributes_for :expenses, :reject_if => :all_blank, :allow_destroy => true

  attr_accessible :event_id, :description, :requester_notes, :tsp_notes, :expenses_attributes, :visa_letter

  validates :event, :presence => true
  validates_associated :expenses
  validate :only_one_active_request, :if => :active?

  scope :active, where(["state <> ?", 'canceled'])
  scope :in_conflict_with, lambda { |req|
    others = active.where(user_id: req.user_id, event_id: req.event_id)
    others = others.where(["id <> ?", req.id]) if req.id
    others
  }

  # Automatic yardoc+graphviz generator is confused by the :unless parameter, so
  # please simply ignore the unless -> has_no_expenses states in the resulting drawing
  state_machine :state, :initial => :incomplete do |machine|
    before_transition :set_state_updated_at

    event :submit do
      transition :incomplete => :submitted, :unless => :has_no_expenses?
    end

    event :approve do
      transition :submitted => :approved
    end

    event :accept do
      transition :approved => :accepted
    end

    event :roll_back do
      # Separated transitions because grouping them using arrays confuses the
      # Graphviz task for automatic documentation
      transition :submitted => :incomplete
      transition :approved => :incomplete
    end

    event :cancel do
      # Separated transitions because grouping them using arrays confuses the
      # Graphviz task for automatic documentation
      transition :incomplete => :canceled
      transition :submitted => :canceled
      transition :approved => :canceled
    end
  end

  # @see HasState.assign_state
  assign_state :submitted, :to => :tsp

  # Checks is expenses.empty?
  #
  # This one line method is required in order to the Graphviz automatic
  # documentation to work, because it doesn't work if a string is used in the
  # :unless parameter of a event definition
  def has_no_expenses?
    expenses.empty?
  end

  # Checks whether the requester should be allowed to do changes.
  #
  # @return [Boolean] true if allowed
  def editable_by_requester?
    state == 'incomplete'
  end

  # Checks whether a tsp user should be allowed to do changes.
  #
  # @return [Boolean] true if allowed
  def editable_by_tsp?
    state == 'submitted'
  end

  # Checks whether a user should be allowed to completely delete the request.
  #
  # @return [Boolean] true if allowed
  def can_be_destroyed?
    not with_transitions?
  end

  # Checks whether the request is ready for reimbursement
  #
  # @return [Boolean] true if all conditions are met
  def can_have_reimbursement?
    accepted?
  end

  # Checks whether a request is ready for reimbursement but the process have not
  # yet started
  #
  # @return [Boolean] if there is no associated reimbursement
  def lacks_reimbursement?
    can_have_reimbursement? and (reimbursement.nil? || reimbursement.new_record?)
  end

  # Check wheter the request is active (currently, 'active' means any state
  # except canceled).
  #
  # @return [Boolean] if the request is active
  def active?
    not canceled?
  end

  # Check wheter the visa_letter attribute can be used
  #
  # @return [Boolean] true if the requester can ask for visa letter
  def visa_letter_allowed?
    event.try(:visa_letters)
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

  protected

  def only_one_active_request
    if Request.in_conflict_with(self).count > 0
      errors.add(:event_id, I18n.t("activerecord.errors.request.only_one_active"))
    end
  end
end
