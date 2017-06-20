class OnlyOneBudgetPerEvent < ActiveRecord::Migration
  def up
    drop_table :budgets_events
    add_column :events, :budget_id, :integer
    add_index :events, :budget_id
  end

  def down
    remove_column :events, :budget_id

    create_table :budgets_events, id: false do |t|
      t.belongs_to :event
      t.belongs_to :budget
    end

    add_index :budgets_events, :event_id
    add_index :budgets_events, :budget_id
  end
end
