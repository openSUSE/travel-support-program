# frozen_string_literal: true

class AddDatesToRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :requests, :incomplete_since, :datetime
    add_column :requests, :submitted_since, :datetime
    add_column :requests, :approved_since, :datetime
    add_column :requests, :accepted_since, :datetime
    add_column :requests, :canceled_since, :datetime
  end
end
