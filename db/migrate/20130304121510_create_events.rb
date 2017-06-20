class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.text :description
      t.string :country_code
      t.string :url
      t.date :start_date
      t.date :end_date
      t.boolean :validated

      t.timestamps
    end
  end
end
