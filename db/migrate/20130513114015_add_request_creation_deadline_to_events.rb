class AddRequestCreationDeadlineToEvents < ActiveRecord::Migration
  def change
    add_column :events, :request_creation_deadline, :datetime
  end
end
