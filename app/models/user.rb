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
  has_one :profile, :class_name => "UserProfile"

  after_create :create_profile

  validates :nickname, :presence => true

  def title; nickname; end

  def find_profile
    profile || create_profile
  end

  def self.with_role(name)
    UserProfile.with_role(name).map(&:user)
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
