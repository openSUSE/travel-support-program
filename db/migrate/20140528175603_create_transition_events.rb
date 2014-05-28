class CreateTransitionEvents < ActiveRecord::Migration
  def change
    create_table :transition_events do |t|
    	t.string :name, :null => false
    	t.string :description
    	t.integer :user_id
    	t.string :machine_type, :null => false
    	t.integer :target_state_id

      t.timestamps
    end
  end
end
