class AddVisaLetterFields < ActiveRecord::Migration
  def change
    add_column :events, :visa_letters, :boolean
    add_column :requests, :visa_letter, :boolean
  end
end
