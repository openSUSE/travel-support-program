class AddPhoneNumberToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :contact_phone_number, :string
  end
end
