class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, :null => false
      t.text :description
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
