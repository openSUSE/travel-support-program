#
# Transition of a state machine (a request, a reimbursement...) from one state
# to another. Saving the StateTransition to the database will correctly update
# the associated state machine automatically.
#
# Saving StateTransition objects to the database is the right way of changing
# the state, as it creates a log of the change, allows the user to add textual
# information and notifies the change to all involved users.
#
class StateTransition < ActiveRecord::Base
  attr_accessible :state_event, :notes, :machine_id, :machine_type

  # The associated state machine (request, reimbursement...)
  belongs_to :machine, :polymorphic => true, :inverse_of => :transitions
  # The user creating the transition
  belongs_to :user

  before_create :fire_state_event
  before_update :prevent_update
  after_create :notify_state

  scope :oldest_first, order("created_at asc")
  scope :newest_first, order("created_at desc")

  protected

  def before_update
    false
  end

  def fire_state_event
    self.from = machine.state
    result = machine.fire_state_event(state_event.to_sym)
    self.to = machine.state
    result
  end

  def notify_state
    machine.notify_state
  end

end
