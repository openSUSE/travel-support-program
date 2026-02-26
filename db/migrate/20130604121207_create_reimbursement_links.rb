# frozen_string_literal: true

class CreateReimbursementLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :reimbursement_links do |t|
      t.references :reimbursement
      t.string :title, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
