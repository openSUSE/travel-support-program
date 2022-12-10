# frozen_string_literal: true

class AddAcceptanceToReimbursement < ActiveRecord::Migration[4.2]
  def change
    add_column :reimbursements, :acceptance_file, :string
  end
end
