class RefactorTransitionFields < ActiveRecord::Migration[4.2]
  def up
    remove_column :reimbursements, :requester_notes
    remove_column :reimbursements, :tsp_notes
    remove_column :reimbursements, :administrative_notes
    remove_column :reimbursements, :incomplete_since
    remove_column :reimbursements, :tsp_pending_since
    remove_column :reimbursements, :tsp_approved_since
    remove_column :reimbursements, :payment_pending_since
    remove_column :reimbursements, :payed_since
    remove_column :reimbursements, :completed_since
    remove_column :reimbursements, :canceled_since
    add_column :reimbursements, :state_updated_at, :datetime

    remove_column :requests, :requester_notes
    remove_column :requests, :tsp_notes
    remove_column :requests, :incomplete_since
    remove_column :requests, :submitted_since
    remove_column :requests, :approved_since
    remove_column :requests, :accepted_since
    remove_column :requests, :canceled_since
    add_column :requests, :state_updated_at, :datetime
  end

  def down
    add_column :reimbursements, :requester_notes, :text
    add_column :reimbursements, :tsp_notes, :text
    add_column :reimbursements, :administrative_notes, :text
    add_column :reimbursements, :incomplete_since, :datetime
    add_column :reimbursements, :tsp_pending_since, :datetime
    add_column :reimbursements, :tsp_approved_since, :datetime
    add_column :reimbursements, :payment_pending_since, :datetime
    add_column :reimbursements, :payed_since, :datetime
    add_column :reimbursements, :completed_since, :datetime
    add_column :reimbursements, :canceled_since, :datetime
    remove_column :reimbursements, :state_updated_at

    add_column :requests, :requester_notes, :text
    add_column :requests, :tsp_notes, :text
    add_column :requests, :incomplete_since, :datetime
    add_column :requests, :submitted_since, :datetime
    add_column :requests, :approved_since, :datetime
    add_column :requests, :accepted_since, :datetime
    add_column :requests, :canceled_since, :datetime
    remove_column :requests, :state_updated_at
  end
end
