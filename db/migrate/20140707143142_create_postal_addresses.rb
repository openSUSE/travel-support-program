# frozen_string_literal: true

class CreatePostalAddresses < ActiveRecord::Migration[4.2]
  def up
    create_table :postal_addresses do |t|
      t.string :line1
      t.string :line2
      t.string :city
      t.string :postal_code
      t.string :county
      t.string :country_code

      t.timestamps
    end

    add_column :shipments, :postal_address_id, :integer
    add_index :shipments, :postal_address_id
    remove_column :shipments, :delivery_address
  end

  def down
    drop_table :postal_addresses
    remove_column :shipments, :postal_address_id
    add_column :shipments, :delivery_address, :text
  end
end
