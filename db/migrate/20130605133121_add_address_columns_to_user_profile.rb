class AddAddressColumnsToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :zip_code, :string
    add_column :user_profiles, :postal_address, :string
  end
end
