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

  state_machine :state, :initial => :incomplete do |machine|

    event :request do
      transition :incomplete => :requested
    end

    event :approve do
      transition :requested => :approved
    end

    event :dispatch do
      transition :approved => :sent
    end

    event :confirm do
      transition :sent => :received
    end

    event :roll_back do
      transition :requested => :incomplete
      transition :approved => :incomplete
    end

    # The empty block for this state is needed to prevent yardoc's error
    # during automatic documentation generation
    state :canceled do
    end
  end

  # @see HasState.responsible_roles
  self.responsible_roles = [:material]
  # @see HasState.assign_state
  assign_state :incomplete, :to => :requester
  assign_state :requested, :to => :material
  assign_state :approved, :to => :shipper
  assign_state :sent, :to => :requester

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
