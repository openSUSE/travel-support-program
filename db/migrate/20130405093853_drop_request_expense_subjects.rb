class DropRequestExpenseSubjects < ActiveRecord::Migration[4.2]
  def up
    drop_table :request_expense_subjects
  end

  def down
    create_table :request_expense_subjects do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
