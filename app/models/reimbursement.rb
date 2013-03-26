#
# Reimbursement for a given request
#
class Reimbursement < ActiveRecord::Base
  # The associated request
  belongs_to :request, :inverse_of => :reimbursement
  # The same of the associated request.
  belongs_to :user
  # The expenses of the associated request, total_amount and authorized_amount
  # will be updated during reimbursement process
  has_many :expenses, :through => :request
  has_many :attachments, :class_name => "ReimbursementAttachment", :inverse_of => :reimbursement

  has_many :state_transitions, :as => :machine

  delegate :event, :to => :request, :prefix => false

  accepts_nested_attributes_for :request, :update_only => true,
    :allow_destroy => false, :reject_if => :reject_request

  accepts_nested_attributes_for :attachments, :allow_destroy => true

  attr_accessible :description, :requester_notes, :tsp_notes, :administrative_notes,
    :request_attributes, :attachments_attributes

  validates :request, :user, :presence => true
  validates_associated :expenses

  # Synchronizes user_id and request_id
  before_validation :set_user_id

  state_machine :state, :initial => :incomplete do
    before_transition :set_state_updated_at

    event :submit do
      transition :incomplete => :tsp_pending
    end

    event :approve do
      transition :tsp_pending => :tsp_approved
    end

    event :authorize do
      transition :tsp_approved => :finished
    end

    event :roll_back do
      transition :tsp_pending => :incomplete
      transition :tsp_approved => :tsp_pending
    end

    event :cancel do
      transition :incomplete => :canceled
      transition :tsp_pending => :canceled
    end
  end

  def expenses_sum(*args)
    request.expenses_sum(*args)
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
    state == 'tsp_pending'
  end

  protected

  # Used internally to synchronize request_id and user_id
  def set_user_id
    self.user_id = request.user_id
  end

  # User internally to set the state_updated_at attribute
  def set_state_updated_at
    self.state_updated_at = DateTime.now
  end

  # Used internally by accepts_nested_attributes to ensure that only
  # total_amount and authorized_amount are accessible through the reimbursement
  #
  # _delete keys are also rejected, so expenses cannot either be deleted
  #
  # @return [Boolean] true if the request should be rejected
  def reject_request(attrs)
    acceptable_request_attrs = %w(id expenses_attributes)
    acceptable_expenses_attrs = %w(id total_amount authorized_amount)
    return true unless (attrs.keys - acceptable_request_attrs).empty?
    if expenses = attrs['expenses_attributes']
      expenses.values.each do |expense|
        return true unless (expense.keys - acceptable_expenses_attrs).empty?
      end
    end
    false
  end
end
