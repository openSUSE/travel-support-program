class AddFieldsToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :second_phone_number, :string
    add_column :user_profiles, :description, :string
    add_column :user_profiles, :location, :string
    add_column :user_profiles, :birthday, :date
    add_column :user_profiles, :website, :string
    add_column :user_profiles, :blog, :string
    add_column :user_profiles, :passport, :string
    add_column :user_profiles, :alternate_id_document, :string
  end
end
