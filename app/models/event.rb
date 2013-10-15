#
# Event is, in some way, the root of the model's hierarchy since any
# Request and any Reimbursement are always associated with an event
#
# Most attributes are self-explanatory except, maybe, the one boolean called
# 'validated'. This attribute is used to control which users can create, update
# and destroy the event.
#
class Event < ActiveRecord::Base
  attr_accessible :name, :description, :start_date, :end_date, :url, :country_code,
    :validated, :visa_letters, :request_creation_deadline, :reimbursement_creation_deadline,
    :budget_id

  # Requests for attending the event
  has_many :requests, :inverse_of => :event, :dependent => :restrict
  # Budget to use as a limit for approved amounts
  belongs_to :budget

  validates :name, :start_date, :end_date, :country_code, :presence => true
  validates :end_date, :date => {:after_or_equal_to => :start_date }

  audit(:create, :update, :destroy) {|m,u,a| "#{a} performed on Event by #{u.try(:nickname)}"}

  default_scope order('name asc')

  # Checks whether the event can be freely updated or destroyed by all users.
  #
  # @return [Boolean] true if any user can modify the object, false if only
  #     authorized users can do it
  def editable_by_requesters?
    not validated
  end

  # Checks whether a user should be allowed to completely delete the event.
  #
  # @return [Boolean] true if allowed
  def can_be_destroyed?
    requests.empty?
  end

  # Check if new requests can be created based on request_creation_deadline
  # and start_date
  #
  # @return [Boolean] true if accepting new requests
  def accepting_requests?
    if request_creation_deadline
      Time.zone.now < request_creation_deadline
    else
      (Date.today < start_date) rescue false
    end
  end

  # Check if new reimbursements can be created based on reimbursement_creation_deadline
  #
  # @return [Boolean] true if accepting new reimbursements
  def accepting_reimbursements?
    if reimbursement_creation_deadline
      Time.zone.now < reimbursement_creation_deadline
    else
      true
    end
  end

  # List of attributed that can only by accessed by users who have validation
  # permissions on the event.
  #
  # @return [Array] a list of the restricted attribute names as symbols
  def self.validation_attributes
    [:validated, :visa_letters, :request_creation_deadline, :reimbursement_creation_deadline]
  end
end
