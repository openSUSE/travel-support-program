class UserProfile < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to_active_hash :role, :class_name => "UserRole", :shortcuts => [:name]

  after_initialize :set_default_attrs, :if => :new_record?
  before_validation do
    self.attributes = connect_attrib_values
  end

  attr_accessible :country_code, :full_name, :location, :passport,
    :alternate_id_document, :birthday, :phone_number, :second_phone_number,
    :website, :blog, :description, :user_role_id

  delegate :name, :to => :role, :prefix => true, :allow_nil => true

  validates :role_id, :presence => true

  audit(:create, :update, :destroy) {|m,u,a| "#{a} performed on UserProfile by #{u.try(:nickname)}"}

  scope :with_role, lambda { |name| where(:role_id => UserRole.find_by_name(name.to_s).id) }

  def set_default_attrs
    self.role_name ||= "requester"
    self.attributes = connect_attrib_values
  end

  FROM_OPENSUSE_CONNECT = {
    :country_code => Proc.new { |c| c.country.split(":").last.upcase},
    :full_name => :name,
    :location => :location,
    :birthday => Proc.new { |c| Date.parse(c.birthday) },
    :phone_number => :mobile,
    :second_phone_number => :phone,
    :website => :website,
    :blog => :blog,
    :description => :briefdescription }

  def refresh
    if TravelSupportProgram::Config.setting :opensuse_auth_proxy, :enabled
      update_attributes(connect_attrib_values)
    else
      true
    end
  end

  def have_editable?(attrib)
    return true unless TravelSupportProgram::Config.setting :opensuse_auth_proxy, :enabled
    not UserProfile::FROM_OPENSUSE_CONNECT.keys.include?(attrib.to_sym)
  end


  protected

  def connect_attrib_values
    return {} unless TravelSupportProgram::Config.setting :opensuse_auth_proxy, :enabled
    new_values = {}
    connect = ConnectUser.new(user.nickname)
    UserProfile::FROM_OPENSUSE_CONNECT.each_pair do |k,v|
      begin
        if v.is_a? Symbol
          new_values[k] = connect.send(v)
        elsif v.is_a? Proc
          new_values[k] = v.call(connect)
        else
          new_values[k] = v
        end
      rescue
        # Do nothing, just keep the current attribute value
        true
      end
    end
    new_values
  end

end
