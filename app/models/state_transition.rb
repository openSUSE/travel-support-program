class StateTransition < ActiveRecord::Base
  attr_accessible :state_event, :notes, :machine_id, :machine_type

  belongs_to :machine, :polymorphic => true
  belongs_to :user
  before_create :fire_state_event
  before_update :prevent_update

  scope :oldest_first, order("created_at asc")
  scope :newest_first, order("created_at desc")

  def before_update
    false
  end

  def fire_state_event
    self.from = machine.state
    result = machine.fire_state_event(state_event.to_sym)
    self.to = machine.state
    result
  end

end
