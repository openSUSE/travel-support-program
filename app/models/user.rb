class User < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :reset_password_token
  attr_accessible :nickname, :locale
  has_one :profile, :class_name => "UserProfile"

  after_create :create_profile

  validates :nickname, :presence => true

  def title; nickname; end

  def find_profile
    profile || create_profile
  end

end
