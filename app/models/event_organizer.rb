# frozen_string_literal: true

class EventOrganizer < ApplicationRecord
  belongs_to :user
  belongs_to :event

  attr_accessor(:user_email)

  validates :user_email, :event_id, presence: true
  validates :user_id, presence: { message: 'No such user exist' }
  validates :user_id, uniqueness: { scope: :event_id, message: 'Already an event organizer for this event' }

  def self.autocomplete_users(term)
    User.order(Arel.sql('lower(nickname)')).where('nickname like ? or email like ?', "%#{term}%", "%#{term}%").pluck(:nickname, :email)
  end
end
