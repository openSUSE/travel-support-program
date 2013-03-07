class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :state
      t.references :user, :null => false
      t.references :event, :null => false
      t.text :description
      t.text :requester_notes
      t.text :tsp_notes

      t.timestamps
    end
    add_index :requests, :user_id
    add_index :requests, :event_id
  end
end
