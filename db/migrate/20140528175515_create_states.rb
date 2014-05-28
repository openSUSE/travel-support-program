class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
    	t.string :name, :null => false
    	t.string :description
    	t.text :temp_comments
    	t.integer :user_id
    	t.string :machine_type, :null => false
    	t.integer :role_id, :null => false     #the field to store the user_role responsible

      t.timestamps
    end
  end
end
