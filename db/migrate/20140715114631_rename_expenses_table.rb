class RenameExpensesTable < ActiveRecord::Migration
  class DummyExpense < ActiveRecord::Base
    self.table_name = "expenses"
  end

  def up
    rename_table :request_expenses, :expenses
    add_column :expenses, :request_type, :string
    add_index :expenses, :request_type

    DummyExpense.update_all :request_type => 'Request'
  end

  def down
    remove_column :expenses, :request_type
    rename_table :expenses, :request_expenses
  end
end
