class CreateEventOrganizers < ActiveRecord::Migration
  def change
    create_table :event_organizers do |t|
      t.references :event
      t.references :user
    end
  end
end
