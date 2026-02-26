# frozen_string_literal: true

#
# Concern for state machines adding some convenient methods, notification
# capabilities and macro-style methods to define permissions
#
module HasState
  extend ActiveSupport::Concern

  included do
    # Requester, that is, the user asking for support
    belongs_to :user
    # State changes are logged as StateChange records
    has_many :state_changes, as: :machine, dependent: :destroy
    # Transitions are logged as StateTransition records
    has_many :transitions, as: :machine, class_name: 'StateTransition'
    # Manual adjustments in the state are logged as StateAdjustment records
    has_many :state_adjustments, as: :machine, class_name: 'StateAdjustment'

    validates :user, presence: true

    before_save :set_state_updated_at

    scope :active, -> { where(['state <> ?', 'canceled']) }
  end

  # Checks whether the object has changed its state at least once in the past, no
  # matters which the current state is.
  #
  # @return [Boolean] true if it has have some transition
  def with_transitions?
    !transitions.empty?
  end

  # Checks if the object have reached a final state
  #
  # @return [Boolean] true if no possible transitions left
  def in_final_state?
    state_events(guard: false).empty?
  end

  # Checks if the object is in the initial state
  #
  # @return [Boolean] true if the current state is the initial one
  def in_initial_state?
    self.class.state_machines[:state].initial_state(self).name == state_name
  end

  # Notify the current state to the users designed using HasState.notify_state
  #
  # @see HasState.notify_to
  def notify_state
    people = self.class.roles_notified_when(state)
    people.map! { |i| i.to_sym == :requester ? user : i }
    HasStateMailer.notify_to(people, :state, self)
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
    return false unless can_cancel?

    self.state = 'canceled'
    save
  end

  # Check whether is active (by default, 'active' means any state
  # except canceled).
  # @see #can_cancel?
  #
  # @return [Boolean] if is active (not canceled)
  def active?
    !canceled?
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
    I18n.t(state, scope: "activerecord.models.#{self.class.model_name.singular}.states")
  end

  # Localized guide of the next step, based in current state
  #
  # return [String] localized guide text
  def human_state_guide
    I18n.t(state, scope: "activerecord.models.#{self.class.model_name.singular}.state_guides")
  end

  # Checks whether the requester should be allowed to do changes.
  #
  # @return [Boolean] true if allowed
  def editable?
    in_initial_state?
  end

  # Checks whether a user should be allowed to completely delete the object.
  #
  # @return [Boolean] true if allowed
  def can_be_destroyed?
    !with_transitions?
  end

  # Label to identify the state machine
  #
  # @return [String] label based in the id
  def label
    "##{id}"
  end

  # Title to show the state machine in the UI
  #
  # @return [String] Class name and label
  def title
    "#{self.class.model_name.human} #{label}"
  end

  protected

  # User internally to set the state_updated_at attribute
  def set_state_updated_at
    self.state_updated_at = Time.current if state_changed? && !state_was.nil?
    true
  end

  #
  # Class methods
  #
  module ClassMethods
    # Macro-style method to define the role which is responsible of the next
    # action for a given state. Currently, this definition is only used to
    # set default filters on lists.
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
        @assigned_states ||= {}
        @assigned_states[to.to_sym] ||= []
        @assigned_states[to.to_sym] << state_name.to_sym
        @assigned_roles ||= {}
        @assigned_roles[state_name.to_sym] ||= []
        @assigned_roles[state_name.to_sym] << to.to_sym
        true
      end
    end

    # Macro-style method to define who should be notified in every state.
    #
    # Understands 3 different options, all of them optional
    #
    # :to            Role or array of roles. Who should be notified when the
    #                machine enters the state. The special value :requester
    #                represent the requester user, despite the user's role.
    #
    # :remind_after  Threshold in seconds. If the machine has been in the same
    #                state for a period of time longer than the threshold, a
    #                reminder notification is sent.
    #
    # :remind_to     Role or array of roles. Reminders will use this, if
    #                present, instead of :to.
    #
    # @param [#to_sym]  state_name  name of the state
    # @param [Hash]     opts  options, as explained in description.
    #
    # @example
    #   notify_state :incomplete, :to => [:tsp, :requester],
    #                             :remind_to => :requester,
    #                             :remind_after => 5.days
    #
    #   notify_state :tsp_pending, :to => [:tsp, :requester],
    #                              :remind_after => 10.days
    def notify_state(state_name, opts = {})
      @notified_roles ||= {}
      @reminder_timeouts ||= {}
      @reminder_roles ||= {}

      st = state_name.to_sym
      to = opts[:to]
      @notified_roles[st] = if to.blank?
                              []
                            else
                              [to].flatten.map(&:to_sym)
                            end

      remind = opts.key?(:remind_to) ? opts[:remind_to] : to
      if remind.blank?
        @reminder_roles[st] = []
        @reminder_timeouts[st] = nil
      else
        @reminder_roles[st] = [remind].flatten.map(&:to_sym)
        @reminder_timeouts[st] = opts[:remind_after]
      end
      true
    end

    # Macro-style method to define which roles are allowed to trigger a
    # transition.
    #
    # It works by defining a method called allow_xxx? (where xxx is the name of
    # the transition). If more complex check is needed, the method can be
    # explicity defined (not using allow_transition).
    #
    # @param [#to_sym] transition_name  one transition
    # @param [Object] roles  can be the name of a role (or the special value
    #       :requester) or an array of names (also supporting :requester)
    def allow_transition(transition_name, roles)
      roles = [roles].flatten.map(&:to_sym)
      define_method :"allow_#{transition_name}?" do |role_name|
        roles.include? role_name.to_sym
      end
    end

    # Defined transitions (including :cancel)
    #
    # @return [Array<Symbol>] transition names, as symbols
    def transitions
      state_machines[:state].events.map(&:name) + [:cancel]
    end

    # Queries the state - role assignation performed via assign_state
    # @see #assign_state
    #
    # @param [Role,#to_sym]  role  role to query
    # @return [Array]  array of states assigned to the given role
    def states_assigned_to(role)
      name = if role.is_a?(UserRole)
               role.name
             else
               role.to_sym
             end
      @assigned_states[name] ? @assigned_states[name].dup : []
    end

    # Queries the state - role assignation performed via assign_state
    # @see #assign_state
    #
    # @param [#to_sym]  state  state to query
    # @return [Array]  array of roles assigned to the given state
    def roles_assigned_to(state)
      @assigned_roles[state.to_sym] ? @assigned_roles[state.to_sym].dup : []
    end

    # Queries the state - role assignation performed via notify_state
    # @see #notify_state
    #
    # @param [#to_sym]  state  state to query
    # @return [Array]  array of roles to notify when the machine reaches
    #                  the given state
    def roles_notified_when(state)
      @notified_roles[state.to_sym] ? @notified_roles[state.to_sym].dup : []
    end

    # Sends notifications for all the objects that are stuck in a given state,
    # according to the timeouts and roles specified using notify_to
    #
    # @see HasState.notify_to
    def notify_inactive
      # Leaf classes send notifications
      if subclasses.blank?
        return true unless @reminder_timeouts

        machines = joins(:user)
        @reminder_timeouts.each do |state, time|
          next unless time

          machines.where(state: state).where(["COALESCE(state_updated_at, #{table_name}.created_at) < ?", time.ago]).each do |m|
            people = @reminder_roles[state].map { |i| i.to_sym == :requester ? m.user : i }
            HasStateMailer.notify_to(people, :state, m)
          end
        end
      # But 'abstract' subclasses delegate to subclasses
      else
        subclasses.each(&:notify_inactive)
        true
      end
    end
  end
end
