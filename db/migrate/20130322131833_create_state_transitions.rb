class CreateStateTransitions < ActiveRecord::Migration
  def change
    create_table :state_transitions do |t|
      t.integer :machine_id,    null: false
      t.string  :machine_type,  null: false
      t.string  :state_event,   null: false
      t.string  :from,          null: false
      t.string  :to,            null: false
      t.integer :user_id
      t.string  :notes

      t.timestamps
    end
  end
end
