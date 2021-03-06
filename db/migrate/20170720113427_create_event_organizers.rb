class CreateEventOrganizers < ActiveRecord::Migration[4.2]
  def change
    create_table :event_organizers do |t|
      t.references :event
      t.references :user
    end
  end
end
