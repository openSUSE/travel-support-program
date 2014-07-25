#
# Request from a user to receive a merchandising box for a designated event
#
class Shipment < Request

  # Comments used to discuss decisions (private) or communicate with the requester (public)
  has_many :comments, :as => :machine, :dependent => :destroy

  # Postal address extracted to another model
  belongs_to :postal_address, :dependent => :destroy, :autosave => true

  accepts_nested_attributes_for :postal_address, :allow_destroy => false

  before_validation :ensure_postal_address

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

  # @see HasState.assign_state
  # @see HasState.notify_to
  assign_state :incomplete, :to => :requester
  notify_state :incomplete, :to => [:requester, :material],
                            :remind_to => :requester,
                            :remind_after => 5.days

  assign_state :requested, :to => :material
  notify_state :requested, :to => [:requester, :material],
                           :remind_after => 10.days

  assign_state :approved, :to => :shipper
  notify_state :approved, :to => [:requester, :material, :shipper],
                          :remind_after => 5.days

  assign_state :sent, :to => :requester
  notify_state :sent, :to => [:requester, :material, :shipper],
                          :remind_after => 15.days

  notify_state :received, :to => [:requester, :material, :shipper]

  notify_state :canceled, :to => [:requester, :material, :shipper]

  # @see HasState.allow_transition
  allow_transition :request, :requester
  allow_transition :approve, :material
  allow_transition :dispatch, :shipper
  allow_transition :confirm, :requester
  allow_transition :roll_back, [:requester, :material]
  allow_transition :cancel, [:requester, :material, :supervisor]

  delegate :shipment_type, to: :event

  # Check is the shipment can still be canceled
  #
  # @return [Boolean] true if it have not been sent yet
  def can_cancel?
    [:incomplete, :requested, :approved].include? state.to_sym
  end

  protected

  def ensure_postal_address
    build_postal_address if postal_address.nil?
  end
end
