module HasState

  extend ActiveSupport::Concern

  included do
    # Requester, that is, the user asking for help.
    belongs_to :user
    # State changes are logged as StateChange records
    has_many :state_changes, :as => :machine, :dependent => :destroy
    # Transitions are logged as StateTransition records
    has_many :transitions, :as => :machine, :class_name => "StateTransition"
    # Manual adjustments in the state are logged as StateAdjustment records
    has_many :state_adjustments, :as => :machine, :class_name => "StateAdjustment"

    validates :user, :presence => true

    before_save :set_state_updated_at

    @assigned_states = {}
    @assigned_roles = {}
  end

  # Checks whether the object has changed its state at least once in the past, no
  # matters which the current state is.
  #
  # @return [Boolean] true if it has have some transition
  def with_transitions?
    not transitions.empty?
  end

  # Checks if the object have reached a final state
  #
  # @return [Boolean] true if no possible transitions left
  def in_final_state?
    state_events(:guard => false).empty?
  end

  # Notify the current state to all involved users
  #
  # Involved users means: requester + users with the tsp or assistant roles + users with
  # the role designed using the macro method assign_state
  def notify_state
    people = ([self.user, :tsp, :assistant] + self.class.roles_assigned_to(state)).uniq - [:requester]
    HasStateMailer::notify_to(people, :state, self, self.human_state_name, self.state_updated_at)
  end

  # Sets the state to 'canceled'
  #
  # It works exactly in the same way that any other transition defined by
  # state_machine. It's implemented in a separate way to keep the workflow as
  # clean as possible. Since a cancelation can happen at any moment,
  # implementing it as a regular transition could lead state_machine to the
  # conclusion that 'canceled' is the only valid final state.
  #
  # return [Boolean] true if the state is updated
  def cancel
    return false if not can_cancel?
    self.state = 'canceled'
    save
  end

  # Check whether is active (by default, 'active' means any state
  # except canceled).
  # @see #can_cancel?
  #
  # @return [Boolean] if is active (not canceled)
  def active?
    not canceled?
  end

  # Checks whether can have a transition to 'canceled' state
  #
  # Compatibility for #cancel with transitions defined by state_machine.
  # Default implementation always return true when active, meaning that
  # a process can be canceled at any moment.
  # Classes using this mixin should implement their own custom behaviour.
  # @see #cancel
  # @see #active?
  #
  # return [Boolean] true if #cancel can be called
  def can_cancel?
    active?
  end

  # Roles assigned to the machine according to its state
  #
  # @see roles_assigned_to
  # @return [Array] list of roles as symbols
  def assigned_roles
    self.class.roles_assigned_to(state)
  end

  # Localized state description, to complete human_state_name
  #
  # return [String] localized description of the current state
  def human_state_description
    I18n.t(self.state, :scope => "activerecord.models.#{self.class.model_name.singular}.states")
  end

  # Localized guide of the next step, based in current state
  #
  # return [String] localized guide text
  def human_state_guide
    I18n.t(self.state, :scope => "activerecord.models.#{self.class.model_name.singular}.state_guides")
  end

  protected

  # User internally to set the state_updated_at attribute
  def set_state_updated_at
    if state_changed? && !state_was.nil?
      self.state_updated_at = Time.current
    end
    true
  end

  #
  # Class methods
  #
  module ClassMethods

    # Roles involved in the workflow at any point (that is, that have
    # any assigned state)
    # @see #assign_state
    # Used for sending important notifications
    def involved_roles; @assigned_states.keys; end

    # Macro-style method to define the role which is responsible of the next
    # action for a given state. This definition is used for sending
    # notifications and also as a default filter on lists.
    #
    # @param [#to_sym]  state_name  name of the state
    # @param [Hash]     opts  :to is the only expected (and mandatory) key
    #
    # @example
    #   assign_state :tsp_pending, :to => :tsp
    def assign_state(state_name, opts = {})
      to = opts[:to]
      if to.blank?
        false
      else
        @assigned_states[to.to_sym] ||= []
        @assigned_states[to.to_sym] << state_name.to_sym
        @assigned_roles[state_name.to_sym] ||= []
        @assigned_roles[state_name.to_sym] << to.to_sym
        true
      end
    end

    # Queries the state - role assignation performed via assign_state
    # @see #assign_state
    #
    # @param [Role,#to_sym]  role  role to query
    # @return [Array]  array of states assigned to the given role
    def states_assigned_to(role)
      if role.kind_of?(UserRole)
        name = role.name
      else
        name = role.to_sym
      end
      @assigned_states[name] || []
    end

    # Queries the state - role assignation performed via assign_state
    # @see #assign_state
    #
    # @param [#to_sym]  state  state to query
    # @return [Array]  array of roles assigned to the given state
    def roles_assigned_to(state)
      @assigned_roles[state.to_sym] || []
    end

    def notify_inactive_since(date)
      where(["state in (?) and state_updated_at < ?", @assigned_roles.keys, date]).joins(:user).each do |m|
        people = roles_assigned_to(m.state).map {|i| i.to_sym == :requester ? m.user : i }
        HasStateMailer::notify_to(people, :state, m, m.human_state_name, m.state_updated_at)
      end
    end
  end
end
