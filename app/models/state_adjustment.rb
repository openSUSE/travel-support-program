#
# Manual and arbitrary adjustment in the state of a state machine (a request,
# reimbursement, etc.) ignoring the transitions definitions in the state
# machine. Saving the StateAdjustment to the database will update the associated
# state machine automatically.
#
# StateAdjustment objects should only be used in situations in which
# StateTransition is not applicable. In order to keep the information as sane
# as possible, state transitions are cleary encouraged instead of state
# adjustments, since the former follows the the state machine specification and
# the later can break the expected workflow.
# @see StateTransition
#
class StateAdjustment < StateChange
  attr_accessible :to

  validate :state_is_changed

  # @see StateChange
  def human_action_name
    I18n.t("activerecord.models.state_change.action_name")
  end

  protected

  def update_machine_state
    # If machine is not present, it will not be saved anyway (because of
    # validations)
    if machine
      self.from = machine.state
      machine.update_attribute :state, to
    end
    true
  end

  def state_is_changed
    errors.add(:to, :state_not_changed) if from.to_s == to.to_s
  end

end
