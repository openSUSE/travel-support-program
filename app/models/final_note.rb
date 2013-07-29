#
# Final note attached to a state machine.
# When the machine reaches a final state, users cannot longer modify the state,
# but they can add comments creating final notes.
#
class FinalNote < ActiveRecord::Base
  attr_accessible :body
  # The associated state machine (request, reimbursement...)
  belongs_to :machine, :polymorphic => true, :inverse_of => :transitions
  # The author of the note
  belongs_to :user

  validates :body, :user_id, :machine, :presence => true

  after_create :notify_creation

  scope :oldest_first, order("created_at asc")
  scope :newest_first, order("created_at desc")

  protected

  def notify_creation
    FinalNoteMailer.notify_to [user] + machine.class.involved_roles - [:requester], :creation, self
  end
end
