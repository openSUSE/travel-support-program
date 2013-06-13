class AddAcceptanceToReimbursement < ActiveRecord::Migration
  def change
    add_column :reimbursements, :acceptance_file, :string
  end
end
