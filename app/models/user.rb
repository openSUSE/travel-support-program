#
# Devise user.
#
# This model only keeps the information and methods needed for authentication.
# For user information or role, use UserProfile
#
class User < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  if TravelSupportProgram::Config.setting(:opensuse_auth_proxy, :enabled)
    devise :opensuse_authenticatable
  else
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

    attr_accessible :password, :password_confirmation, :remember_me, :reset_password_token
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email
  attr_accessible :nickname, :locale
  # Associated object with all information not directly related to authentication
  has_one :profile, :class_name => "UserProfile"
  # Requests created by the user
  has_many :requests, :inverse_of => :user
  # Reimbursements created by the user
  has_many :reimbursements, :inverse_of => :user
  # State changes (transitions or manual adjustments) performed by the user
  has_many :state_changes, :inverse_of => :user

  after_create :create_profile

  validates :nickname, :presence => true

  def title; nickname; end

  def find_profile
    profile || create_profile
  end

  def self.with_role(role)
    UserProfile.with_role(role).map(&:user)
  end

  def self.find_or_create_from_opensuse(username, email)
    if user = find_by_nickname(username)
      update_all({:email => email}, {:id => user.id}) if user.email != email
    else
      user = create(nickname: username, email: email)
    end
    user
  end
end
