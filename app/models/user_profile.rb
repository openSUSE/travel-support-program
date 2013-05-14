class UserProfile < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to_active_hash :role, :class_name => "UserRole", :shortcuts => [:name]

  after_initialize :set_default_attrs, :if => :new_record?

  attr_accessible :country_code, :full_name, :location, :passport,
    :alternate_id_document, :birthday, :phone_number, :second_phone_number,
    :website, :blog, :description, :user_role_id

  delegate :name, :to => :role, :prefix => true, :allow_nil => true

  validates :role_id, :presence => true

  audit(:create, :update, :destroy) {|m,u,a| "#{a} performed on UserProfile by #{u.try(:nickname)}"}

  scope :with_role, lambda { |name| where(:role_id => UserRole.find_by_name(name.to_s).id) }

  def set_default_attrs
    self.role_name ||= "requester"
  end

end
