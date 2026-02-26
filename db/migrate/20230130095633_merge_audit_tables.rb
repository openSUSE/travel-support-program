# frozen_string_literal: true

class MergeAuditTables < ActiveRecord::Migration[5.1]
  def self.up
    execute 'INSERT INTO audits(auditable_id, auditable_type, user_id, user_type, action, audited_changes, version, comment, remote_address, created_at) ' \
            'SELECT auditable_id, auditable_type, user_id, user_type, action, audited_changes, version, comment, remote_address, created_at FROM espinita_audits;'
    drop_table :espinita_audits
  end

  def self.down
    raise IrreversibleMigration
  end
end
