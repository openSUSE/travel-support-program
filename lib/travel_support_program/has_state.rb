module TravelSupportProgram
  module HasState
    def self.included(base)
      base.class_eval do
        # Requester, that is, the user asking for help.
        belongs_to :user
        # Transitions are logged as StateTransition records
        has_many :transitions, :as => :machine, :class_name => "StateTransition"

        validates :user, :presence => true

        @assigned_states = {}
        @assigned_roles = {}
      end
      base.extend(ClassMethods)
    end

    # Checks whether the object has changed its state at least once in the past, no
    # matters which the current state is.
    #
    # @return [Boolean] true if it has have some transition
    def with_transitions?
      not transitions.empty?
    end

    # Notify the current state to all involved users
    #
    # Involved users means: requester + users with the tsp role + users with
    # the roles designed using the macro method assign_state_to
    def notify_state
      roles = ([:tsp] + self.class.roles_assigned_to(state)).uniq
      HasStateMailer::notify_state(self, roles)
    end

    protected

    # User internally to set the state_updated_at attribute
    def set_state_updated_at
      self.state_updated_at = DateTime.now
    end

    #
    # Class methods
    #
    module ClassMethods

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
    end
  end
end
