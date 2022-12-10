# frozen_string_literal: true

#
# Devise user.
#
# This model only keeps the information and methods needed for authentication.
# For user information or role, use UserProfile
#
class User < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  devise_modules = []
  devise_modules += %i[ichain_authenticatable ichain_registerable] if Rails.configuration.site['authentication']['ichain']['enabled']
  if Rails.configuration.site['authentication']['database']['enabled']
    devise_modules += %i[database_authenticatable registerable recoverable
                         rememberable trackable validatable]
  end

  devise(*devise_modules)

  # Setup accessible (or protected) attributes for your model
  # Associated object with all information not directly related to authentication
  has_one :profile, class_name: 'UserProfile'
  # Requests created by the user
  has_many :requests, inverse_of: :user
  # Reimbursements created by the user
  has_many :reimbursements, inverse_of: :user
  # State changes (transitions or manual adjustments) performed by the user
  has_many :state_changes, inverse_of: :user
  # Event Emails send by a user
  has_many :event_emails
  # Event organizer for events
  has_many :event_organizers
  # Events for which the user is an event organizer
  has_many :organizing_events, through: :event_organizers, source: :event

  after_create :create_profile

  validates :nickname, presence: true

  def title
    nickname
  end

  def find_profile
    profile || create_profile
  end

  def self.with_role(role)
    UserProfile.with_role(role).map(&:user)
  end

  def self.for_ichain_username(username, attributes)
    if user = find_by_nickname(username)
      where(id: user.id).update_all(email: attributes[:email]) if user.email != attributes[:email]
    else
      user = create(nickname: username, email: attributes[:email])
    end
    user
  end
end
