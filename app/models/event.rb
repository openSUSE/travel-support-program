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
    :validated, :visa_letters, :request_creation_deadline
  has_many :requests, :inverse_of => :event

  validates :name, :start_date, :end_date, :country_code, :presence => true
  validates :end_date, :date => {:after_or_equal_to => :start_date }

  audit(:create, :update, :destroy) {|m,u,a| "#{a} performed on Event by #{u.try(:nickname)}"}

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
    open = (Date.today < start_date) rescue false
    if open && request_creation_deadline
      open = Time.now < request_creation_deadline
    end
    open
  end

  # List of attributed that can only by accessed by users who have validation
  # permissions on the event.
  #
  # @return [Array] a list of the restricted attribute names as symbols
  def self.validation_attributes
    [:validated, :visa_letters, :request_creation_deadline]
  end
end
