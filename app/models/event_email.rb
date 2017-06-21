class EventEmail < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  validates :to, presence: true
  validates :subject, presence: true, length: { maximum: 150 }
  validates :body, presence: true
end
