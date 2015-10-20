class AddPrecision < ActiveRecord::Migration
  def up
    change_column :budgets, :amount, :decimal, precision: 10, scale: 2
    change_column :payments, :amount, :decimal, precision: 10, scale: 2
    change_column :payments, :cost_amount, :decimal, precision: 10, scale: 2
    change_column :request_expenses, :estimated_amount, :decimal, precision: 10, scale: 2
    change_column :request_expenses, :approved_amount, :decimal, precision: 10, scale: 2
    change_column :request_expenses, :total_amount, :decimal, precision: 10, scale: 2
    change_column :request_expenses, :authorized_amount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :budgets, :amount, :decimal
    change_column :payments, :amount, :decimal
    change_column :payments, :cost_amount, :decimal
    change_column :request_expenses, :estimated_amount, :decimal
    change_column :request_expenses, :approved_amount, :decimal
    change_column :request_expenses, :total_amount, :decimal
    change_column :request_expenses, :authorized_amount, :decimal
  end
end
