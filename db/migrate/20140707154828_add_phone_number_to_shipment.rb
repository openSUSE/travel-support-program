class AddPhoneNumberToShipment < ActiveRecord::Migration[4.2]
  def change
    add_column :shipments, :contact_phone_number, :string
  end
end
