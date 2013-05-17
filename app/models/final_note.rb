class FinalNote < ActiveRecord::Base
  attr_accessible :body
  belongs_to :machine, :polymorphic => true, :inverse_of => :transitions
  belongs_to :user

  validates :body, :user_id, :machine, :presence => true

  after_create :notify_creation

  scope :oldest_first, order("created_at asc")
  scope :newest_first, order("created_at desc")

  protected

  def notify_creation
    FinalNoteMailer.notify_to [user] + machine.class.involved_roles, :creation, self
  end
end
