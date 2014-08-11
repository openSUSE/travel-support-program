#
# Request from a user to receive a merchandising box for a designated event
#
class Shipment < ActiveRecord::Base
  include HasState

  # The event associated to the state machine
  belongs_to :event

  # Comments used to discuss decisions (private) or communicate with the requester (public)
  has_many :comments, :as => :machine, :dependent => :destroy

  validates :event, :presence => true

  auditable


  # @see HasState.responsible_roles
  self.responsible_roles = [:material]
  # @see HasState.assign_state
  assign_state :incomplete, :to => :requester
  assign_state :requested, :to => :material
  assign_state :approved, :to => :shipper
  assign_state :sent, :to => :requester

  # Current implementation for creating state_machine from dynamic content

  # defining method_missing to handle requests through machine class
  def method_missing(method, *args, &block)
    if machine.respond_to?(method)
      machine.send(method, *args, &block)
    else
      super
    end
  end

  # Defining seperate methods for the state attribute to prevent confusion between Shipment#state
  # and Machine#state
  def state=(text)
    write_attribute(:state,text)
  end

  def state
    read_attribute(:state)
  end

  def cancel_role?(role)
    [1,3,6].include?(role.id)
  end

  # Type of the shipment
  #
  # @return [String] type label, delegated to the associated event
  def type
    event.try(:shipment_type)
  end

  # Check is the shipment can still be canceled
  #
  # @return [Boolean] true if it have not been sent yet
  def can_cancel?
    [:incomplete, :requested, :approved].include? state.to_sym
  end

end
