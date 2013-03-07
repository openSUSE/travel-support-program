class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.references :user, :null => false
      t.integer :role_id, :null => false
      t.string :full_name
      t.string :phone_number
      t.string :country_code

      t.timestamps
    end
  end
end
