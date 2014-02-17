class RenameFinalNotes < ActiveRecord::Migration
  class DummyComment < ActiveRecord::Base
    self.table_name = "comments"
  end

  def up
    rename_table :final_notes, :comments
    add_column :comments, :private, :boolean
    add_index :comments, :private

    DummyComment.update_all :private => false
  end

  def down
    remove_index :comments, :private
    remove_column :comments, :private
    rename_table :comments, :final_notes
  end
end
