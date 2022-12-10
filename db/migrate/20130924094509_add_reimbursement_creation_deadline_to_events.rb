# frozen_string_literal: true

class AddReimbursementCreationDeadlineToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :reimbursement_creation_deadline, :datetime
  end
end
