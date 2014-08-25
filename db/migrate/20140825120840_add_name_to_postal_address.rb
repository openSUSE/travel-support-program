class AddNameToPostalAddress < ActiveRecord::Migration
  def change
    add_column :postal_addresses, :name, :string
  end
end
