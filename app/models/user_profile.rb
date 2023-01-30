# frozen_string_literal: true

#
# This model is used to keep most of the information related to the user
# identity and role, in order to keep the User model as empty as possible.
# The User model only contains fields and associations that are strictly
# related to authentication.
#
class UserProfile < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  # The associated user (one to one association)
  belongs_to :user
  # The role of the user in the application (mainly used for permissions)
  belongs_to_active_hash :role, class_name: 'UserRole', shortcuts: [:name]

  after_initialize :set_default_attrs, if: :new_record?

  delegate :name, to: :role, prefix: true, allow_nil: true

  validates :role_id, presence: true

  audited

  scope :with_role, lambda { |role|
    if role.is_a?(UserRole)
      where(role_id: role.id)
    else
      where(role_id: UserRole.find_by_name(role.to_s).id)
    end
  }

  def set_default_attrs
    self.role_name ||= 'none'
  end

  # List of fields that are required for processing reimbursements but are
  # not present. The list of fields is set as a configuration parameter for
  # the application.
  #
  # @return [Hash] hash with the name of the fields as keys and its
  #             human-readable names as values
  def missing_fields
    fields = Rails.configuration.site['relevant_profile_fields']
    fields = fields.select { |f| send(f.to_sym).blank? }
    Hash[fields.map { |f| [f, self.class.human_attribute_name(f)] }]
  end
end
