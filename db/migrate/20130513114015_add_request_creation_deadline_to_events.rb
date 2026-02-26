# frozen_string_literal: true

class AddRequestCreationDeadlineToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :request_creation_deadline, :datetime
  end
end
