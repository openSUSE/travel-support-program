class CreateBankAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_accounts do |t|
      t.string :holder
      t.string :bank_name
      t.string :format
      t.string :iban
      t.string :bic
      t.string :national_bank_code
      t.string :national_account_code
      t.string :country_code
      t.string :bank_postal_address
      t.references :reimbursement

      t.timestamps
    end
  end
end
