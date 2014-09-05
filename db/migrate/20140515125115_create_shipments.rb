class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.string      :state
      t.references  :user
      t.references  :event
      t.text        :delivery_address
      t.text        :description
      t.datetime    :state_updated_at

      t.timestamps
    end
  end
end
