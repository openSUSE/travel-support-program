#
# This model is used to keep most of the information related to the user
# identity and role, in order to keep the User model as empty as possible.
# The User model only contains fields and associations that are strictly
# related to authentication.
#
class UserProfile < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  # The associated user (one to one association)
  belongs_to :user
  # The role of the user in the application (mainly used for permissions)
  belongs_to_active_hash :role, :class_name => "UserRole", :shortcuts => [:name]

  after_initialize :set_default_attrs, :if => :new_record?
  before_validation do
    self.attributes = connect_attrib_values
  end

  attr_accessible :country_code, :full_name, :location, :passport,
    :alternate_id_document, :birthday, :phone_number, :second_phone_number,
    :website, :blog, :description, :user_role_id,
    :postal_address, :zip_code

  delegate :name, :to => :role, :prefix => true, :allow_nil => true

  validates :role_id, :presence => true

  audit(:create, :update, :destroy) {|m,u,a| "#{a} performed on UserProfile by #{u.try(:nickname)}"}

  scope :with_role, lambda { |role|
    if role.kind_of?(UserRole)
      where(:role_id => role.id)
    else
      where(:role_id => UserRole.find_by_name(role.to_s).id)
    end
  }

  def set_default_attrs
    self.role_name ||= "requester"
    self.attributes = connect_attrib_values
  end

  # Attributed that are fetched from openSUSE Connect
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

  # Fetchs fresh information from an external source (only openSUSE Connect at
  # this moment) and updates the database.
  # 
  # @return [Boolean] true if the information is correctly updated
  def refresh
    if TravelSupportProgram::Config.setting :opensuse_auth_proxy, :enabled
      update_attributes(connect_attrib_values)
    else
      true
    end
  end

  # Checks if a given attribute is editable.
  #
  # @param [#to_sym] attrib attribute name
  # @return [Boolean] true unless the attributes is mean to be fetched from an
  #       external source (openSUSE Connect at this moment)
  def have_editable?(attrib)
    return true unless TravelSupportProgram::Config.setting :opensuse_auth_proxy, :enabled
    not UserProfile::FROM_OPENSUSE_CONNECT.keys.include?(attrib.to_sym)
  end

  # Checks whether all the fields that are required for processing
  # reimbursements are present. The list of fields is set as a configuration
  # parameter for the application.
  #
  # @return [Boolean] true unless some of the required attributes is missing
  def complete?
    fields = TravelSupportProgram::Config.setting(:relevant_profile_fields)
    return true if fields.blank?
    fields.each do |f|
      return false if send(f.to_sym).blank?
    end
    true
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
