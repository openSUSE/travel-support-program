#
# Transition of a state machine (a request, a reimbursement...) from one state
# to another, using the state machine methods. Saving the StateTransition to the
# database will correctly update the associated state machine automatically.
#
class StateTransition < StateChange
  validates :state_event, presence: true

  # @see StateChange
  def human_action_name
    I18n.t("activerecord.state_machines.events.#{state_event}")
  end

  protected

  def update_machine_state
    self.from = machine.state
    result = if state_event.to_sym == :cancel
               machine.cancel
             else
               machine.fire_state_event(state_event.to_sym)
             end
    self.to = machine.state
    result
  end
end
