class RenameStateTransitions < ActiveRecord::Migration[4.2]
  class DummyStateChange < ActiveRecord::Base
    self.table_name = 'state_changes'
  end

  def up
    rename_table :state_transitions, :state_changes
    add_column :state_changes, :type, :string
    change_column :state_changes, :state_event, :string, null: true
    add_index :state_changes, :type

    DummyStateChange.update_all type: 'StateTransition'
  end

  def down
    remove_index :state_changes, :type
    remove_column :state_changes, :type
    rename_table :state_changes, :state_transitions
    change_column :state_transitions, :state_event, :string, null: false
  end
end
