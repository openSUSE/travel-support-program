class AddShipmentTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :shipment_type, :string
  end
end
