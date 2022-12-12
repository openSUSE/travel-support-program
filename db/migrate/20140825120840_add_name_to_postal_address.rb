# frozen_string_literal: true

class AddNameToPostalAddress < ActiveRecord::Migration[4.2]
  def change
    add_column :postal_addresses, :name, :string
  end
end
