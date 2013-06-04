class CreateReimbursementLinks < ActiveRecord::Migration
  def change
    create_table :reimbursement_links do |t|
      t.references :reimbursement
      t.string :title, :null => false
      t.string :url, :null => false

      t.timestamps
    end
  end
end
