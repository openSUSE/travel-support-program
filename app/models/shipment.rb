#
# Request from a user to receive a merchandising box for a designated event
#
class Shipment < Request

  # Postal address extracted to another model
  belongs_to :postal_address, :dependent => :destroy, :autosave => true

  accepts_nested_attributes_for :postal_address, :allow_destroy => false

  before_validation :ensure_postal_address

  # @see HasComments.allow_all_comments_to
  allow_all_comments_to :material
  # @see HasComments.allow_public_comments_to
  allow_public_comments_to [:shipper, :requester]

  state_machine :state, :initial => :incomplete do |machine|

    event :submit do
      transition :incomplete => :submitted
    end

    event :approve do
      transition :submitted => :approved
    end

    event :dispatch do
      transition :approved => :sent
    end

    event :confirm do
      transition :sent => :received
    end

    event :roll_back do
      transition :submitted => :incomplete
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

  assign_state :submitted, :to => :material
  notify_state :submitted, :to => [:requester, :material],
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
  allow_transition :submit, :requester
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
    [:incomplete, :submitted, :approved].include? state.to_sym
  end

  # Populate some fields with information read from the event and the user
  # profile, creating the associated PostalAddress object if it's missing
  #
  # @param [User] contact user to read the information from. By default, the one
  #             associated to the request.
  def populate_contact_info(contact = self.user)
    self.build_postal_address if postal_address.nil?
    postal_address.country_code ||= event.country_code unless event.nil?
    if contact
      profile = contact.profile
      # Phone number
      self.contact_phone_number ||= profile.phone_number
      self.contact_phone_number = profile.second_phone_number if contact_phone_number.blank?
      # Name
      postal_address.name ||= profile.full_name
      postal_address.name = contact.nickname if postal_address.name.blank?
    end
  end

  protected

  def ensure_postal_address
    build_postal_address if postal_address.nil?
  end
end
