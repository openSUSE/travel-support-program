module TravelSupportProgram
  module HasState
    def self.included(base)
      base.class_eval do
        # Requester, that is, the user asking for help.
        belongs_to :user
        # Transitions are logged as StateTransition records
        has_many :transitions, :as => :machine, :class_name => "StateTransition"

        validates :user, :presence => true

        state_machine :state do
          before_transition :set_state_updated_at
          after_transition :notify_state
        end

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

      def states_assigned_to(role)
        if role.kind_of?(UserRole)
          name = role.name
        else
          name = role.to_sym
        end
        @assigned_states[name] || []
      end

      def roles_assigned_to(state)
        @assigned_roles[state.to_sym] || []
      end
    end
  end
end
