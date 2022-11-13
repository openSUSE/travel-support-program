class CreateRequestExpenseSubjects < ActiveRecord::Migration[4.2]
  def change
    create_table :request_expense_subjects do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
