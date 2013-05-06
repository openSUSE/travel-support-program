class FinalNote < ActiveRecord::Base
  attr_accessible :body
  belongs_to :machine, :polymorphic => true, :inverse_of => :transitions
  belongs_to :user

  validates :body, :user_id, :machine, :presence => true

  scope :oldest_first, order("created_at asc")
  scope :newest_first, order("created_at desc")
end
