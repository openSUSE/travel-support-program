#
# Event is, in some way, the root of the model's hierarchy since any
# Request and any Reimbursement are always associated with an event
#
# Most attributes are self-explanatory except, maybe, the one boolean called
# 'validated'. This attribute is used to control which users can create, update
# and destroy the event.
#
class Event < ActiveRecord::Base
  attr_accessible :name, :description, :start_date, :end_date, :url, :country_code, :validated
  has_many :requests, :inverse_of => :event

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

  # List of attributed that can only by accessed by users who have validation
  # permissions on the event.
  #
  # @return [Array] a list of the restricted attribute names as symbols
  def self.validation_attributes
    [:validated]
  end
end
