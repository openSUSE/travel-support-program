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
  belongs_to_active_hash :role, class_name: 'UserRole', shortcuts: [:name]

  after_initialize :set_default_attrs, if: :new_record?
  before_validation do
    self.attributes = connect_attrib_values
  end

  delegate :name, to: :role, prefix: true, allow_nil: true

  validates :role_id, presence: true

  auditable

  scope :with_role, lambda { |role|
    if role.is_a?(UserRole)
      where(role_id: role.id)
    else
      where(role_id: UserRole.find_by_name(role.to_s).id)
    end
  }

  def set_default_attrs
    self.role_name ||= 'none'
    self.attributes = connect_attrib_values
  end

  # Attributed that are fetched from openSUSE Connect
  FROM_OPENSUSE_CONNECT = {
    country_code: proc { |c| c.country.split(':').last.upcase },
    full_name: :name,
    location: :location,
    birthday: proc { |c| Date.parse(c.birthday) },
    phone_number: :mobile,
    second_phone_number: :phone,
    website: :website,
    blog: :blog,
    description: :briefdescription
  }.freeze

  # Fetchs fresh information from an external source (only openSUSE Connect at
  # this moment) and updates the database.
  #
  # @return [Boolean] true if the information is correctly updated
  def refresh
    if TravelSupport::Config.setting :opensuse_connect, :enabled
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
    return true unless TravelSupport::Config.setting :opensuse_connect, :enabled
    !UserProfile::FROM_OPENSUSE_CONNECT.keys.include?(attrib.to_sym)
  end

  # List of fields that are required for processing reimbursements but are
  # not present. The list of fields is set as a configuration parameter for
  # the application.
  #
  # @return [Hash] hash with the name of the fields as keys and its
  #             human-readable names as values
  def missing_fields
    fields = TravelSupport::Config.setting(:relevant_profile_fields)
    fields = fields.select { |f| send(f.to_sym).blank? }
    Hash[fields.map { |f| [f, self.class.human_attribute_name(f)] }]
  end

  protected

  def connect_attrib_values
    return {} unless TravelSupport::Config.setting :opensuse_connect, :enabled
    new_values = {}
    connect = ConnectUser.new(user.nickname)
    UserProfile::FROM_OPENSUSE_CONNECT.each_pair do |k, v|
      begin
        new_values[k] = if v.is_a? Symbol
                          connect.send(v)
                        elsif v.is_a? Proc
                          v.call(connect)
                        else
                          v
                        end
      rescue
        # Do nothing, just keep the current attribute value
        true
      end
    end
    new_values
  end
end
