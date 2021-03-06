class CreateFinalNotes < ActiveRecord::Migration[4.2]
  def change
    create_table :final_notes do |t|
      t.integer :machine_id
      t.string  :machine_type
      t.text    :body
      t.references :user
      t.timestamps
    end
  end
end
