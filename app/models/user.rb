#
# Devise user.
#
# This model only keeps the information and methods needed for authentication.
# For user information or role, use UserProfile
#
class User < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  devise_modules = []
  if TravelSupport::Config.setting(:authentication, :ichain, :enabled)
    devise_modules += [:ichain_authenticatable, :ichain_registerable]
  end
  if TravelSupport::Config.setting(:authentication, :database, :enabled)
    devise_modules += [:database_authenticatable, :registerable, :recoverable,
      :rememberable, :trackable, :validatable]
  end

  devise *devise_modules

  # Setup accessible (or protected) attributes for your model
  # Associated object with all information not directly related to authentication
  has_one :profile, :class_name => "UserProfile"
  # Requests created by the user
  has_many :requests, :inverse_of => :user
  # Reimbursements created by the user
  has_many :reimbursements, :inverse_of => :user
  # State changes (transitions or manual adjustments) performed by the user
  has_many :state_changes, :inverse_of => :user
  # Customised states created by the user
  has_many :states, :inverse_of => :user
  # Customised transition_events created by the user
  has_many :transition_events, :inverse_of => :user

  after_create :create_profile

  validates :nickname, :presence => true

  def title; nickname; end

  def find_profile
    profile || create_profile
  end

  def self.with_role(role)
    UserProfile.with_role(role).map(&:user)
  end

  def self.for_ichain_username(username, attributes)
    if user = find_by_nickname(username)
      update_all({:email => attributes[:email]}, {:id => user.id}) if user.email != attributes[:email]
    else
      user = create(nickname: username, email: attributes[:email])
    end
    user
  end
end
