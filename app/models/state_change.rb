#
# @abstract Change in the state of a state machine (a request, reimbursement,
# etc.). This class is not intended to be used directly, use one of the
# subclasses instead.
#
# Using a subclass of StateChange is the right way of changing the state of
# any state machine, since it creates a log of the change, allows the user to
# add textual information and notifies the change to all involved users. Don't
# modify the state or call the state machine transition methods directly.
# @see StateTransition
# @see StateAdjustment
#
class StateChange < ActiveRecord::Base
  attr_accessible :machine_id, :machine_type, :notes

  before_validation :update_machine_state, :on => :create
  before_update :prevent_update
  after_create :notify_state

  # The associated state machine (request, reimbursement...)
  belongs_to :machine, :polymorphic => true, :inverse_of => :state_changes
  # The user creating the change
  belongs_to :user, :inverse_of => :state_changes

  validates :from, :to, :user, :machine, :presence => true

  scope :oldest_first, -> { order("created_at asc") }
  scope :newest_first, -> { order("created_at desc") }

  # Short and human readable explanation of the change. To be implemented by
  # subclasses.
  #
  # @return [String]
  def human_action_name
    raise NotImplementedError
  end

  protected

  def prevent_update
    false
  end

  def update_machine_state
    # Prevent saving if the method have not been redefined in the subclass
    false
  end

  def notify_state
    machine.notify_state
  end
end
