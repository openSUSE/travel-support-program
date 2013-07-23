#
# Devise user.
#
# This model only keeps the information and methods needed for authentication.
# For user information or role, use UserProfile
#
class User < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  devise_modules = []
  if TravelSupportProgram::Config.setting(:authentication, :ichain, :enabled)
    devise_modules += [:ichain_authenticatable, :ichain_registerable]
  end
  if TravelSupportProgram::Config.setting(:authentication, :database, :enabled)
    devise_modules += [:database_authenticatable, :registerable, :recoverable,
      :rememberable, :trackable, :validatable]

    attr_accessible :password, :password_confirmation, :remember_me, :reset_password_token
  end

  devise *devise_modules

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email
  attr_accessible :nickname, :locale
  # Associated object with all information not directly related to authentication
  has_one :profile, :class_name => "UserProfile"

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
