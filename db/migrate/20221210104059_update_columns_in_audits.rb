# frozen_string_literal: true

class UpdateColumnsInAudits < ActiveRecord::Migration[5.1]
  def change
    add_column :audits, :remote_address, :string
    add_column :audits, :username, :string
    add_column :audits, :request_uuid, :string
    add_column :audits, :associated_id, :integer
    add_column :audits, :associated_type, :string

    change_column_null :audits, :auditable_id, true
    change_column_null :audits, :auditable_type, true
    change_column_null :audits, :action, true
    change_column_null :audits, :created_at, true

    remove_index :audits, name: :auditable_index

    add_index :audits, :request_uuid
    add_index :audits, %i[auditable_type auditable_id version], name: :auditable_index
    add_index :audits, %i[associated_type associated_id], name: :associated_index

    remove_column :audits, :owner_id, :integer
    remove_column :audits, :owner_type, :string
  end
end
