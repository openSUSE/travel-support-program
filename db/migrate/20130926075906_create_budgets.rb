class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.string :name
      t.string :description
      t.decimal :amount,      precision: 10, scale: 2
      t.string :currency

      t.timestamps
    end

    create_table :budgets_events, :id => false do |t|
      t.belongs_to :event
      t.belongs_to :budget
    end

    add_index :budgets_events, :event_id
    add_index :budgets_events, :budget_id
    add_index :budgets, :currency
  end
end
