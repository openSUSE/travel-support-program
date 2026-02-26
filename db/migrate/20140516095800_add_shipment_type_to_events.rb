# frozen_string_literal: true

class AddShipmentTypeToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :shipment_type, :string
  end
end
