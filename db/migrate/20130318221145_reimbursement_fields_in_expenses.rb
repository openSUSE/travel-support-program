class ReimbursementFieldsInExpenses < ActiveRecord::Migration
  def up
    rename_column :request_expenses, :total_amount, :estimated_amount
    rename_column :request_expenses, :total_currency, :estimated_currency
    add_column :request_expenses, :total_amount, :decimal,   precision: 10, scale: 2
    add_column :request_expenses, :authorized_amount, :decimal,   precision: 10, scale: 2
  end

  def down
    remove_column :request_expenses, :total_amount
    remove_column :request_expenses, :authorized_amount
    rename_column :request_expenses, :estimated_amount, :total_amount
    rename_column :request_expenses, :estimated_currency, :total_currency
  end
end
