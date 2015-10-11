class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references  :reimbursement
      t.date        :date
      t.decimal     :amount,      precision: 10, scale: 2
      t.string      :currency
      t.decimal     :cost_amount,      precision: 10, scale: 2
      t.string      :cost_currency
      t.string      :method
      t.string      :code
      t.string      :subject
      t.text        :notes
      t.string      :file

      t.timestamps
    end
  end
end
