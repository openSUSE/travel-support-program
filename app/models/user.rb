class User < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :reset_password_token
  attr_accessible :nickname, :locale, :user_role_id

  has_one :profile, :class_name => "UserProfile"
  belongs_to_active_hash :role, :class_name => "UserRole", :shortcuts => [:name]

  delegate :name, :to => :role, :prefix => true, :allow_nil => true

  after_create :create_profile
  after_initialize :set_default_attrs, :if => :new_record?

  validates :role_id, :presence => true

  def find_profile
    profile || create_profile
  end

  def set_default_attrs
    self.role_name ||= "requester"
  end

end
