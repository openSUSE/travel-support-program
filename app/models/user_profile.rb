class UserProfile < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to_active_hash :role, :class_name => "UserRole", :shortcuts => [:name]

  after_initialize :set_default_attrs, :if => :new_record?

  attr_accessible :country_code, :full_name, :phone_number, :user_role_id

  delegate :name, :to => :role, :prefix => true, :allow_nil => true

  validates :role_id, :presence => true

  def set_default_attrs
    self.role_name ||= "requester"
  end

end
