class CreateRequestExpenses < ActiveRecord::Migration
  def change
    create_table :request_expenses do |t|
      t.references :request, null: false
      t.string :subject
      t.string :description
      t.decimal :total_amount
      t.string :total_currency
      t.decimal :approved_amount
      t.string :approved_currency

      t.timestamps
    end
  end
end
