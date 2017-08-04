class EventOrganizer < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  attr_accessor(:user_email)

  validates :user_email, presence: true
  validates :user_id, uniqueness: { scope: :event_id, message: 'Already an event organizer for this event' }
end
