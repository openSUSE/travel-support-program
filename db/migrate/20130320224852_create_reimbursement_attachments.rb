class CreateReimbursementAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :reimbursement_attachments do |t|
      t.references :reimbursement
      t.string :title, null: false
      t.string :file, null: false

      t.timestamps
    end
  end
end
