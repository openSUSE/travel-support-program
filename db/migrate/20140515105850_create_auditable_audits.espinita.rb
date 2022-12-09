# This migration comes from espinita (originally 20131029200927)
class CreateAuditableAudits < ActiveRecord::Migration[4.2]
  def change
    create_table :espinita_audits do |t|
      t.references :auditable, polymorphic: true, index: true
      t.references :user, polymorphic: true, index: true
      t.text :audited_changes
      t.string :comment
      t.integer :version
      t.string :action
      t.string :remote_address

      t.timestamps
    end
  end
end
