class AddReimbursementCreationDeadlineToEvents < ActiveRecord::Migration
  def change
    add_column :events, :reimbursement_creation_deadline, :datetime
  end
end
