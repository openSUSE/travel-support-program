class CreateEventEmails < ActiveRecord::Migration[4.2]
  def change
    create_table :event_emails do |t|
      t.text	:to
      t.string	:subject
      t.text	:body
      t.belongs_to	:user
      t.belongs_to	:event

      t.timestamps
    end
  end
end
