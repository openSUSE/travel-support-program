# frozen_string_literal: true

class NormalizeSqliteBooleans < ActiveRecord::Migration[5.2]
  def up
    return unless connection.adapter_name == 'SQLite'

    # Rails 6 removes the legacy t/f representation. Convert stored values
    # before application code starts reading them with the new adapter.
    connection.tables.each do |table|
      connection.columns(table).select { |column| column.type == :boolean }.each do |column|
        quoted_table = connection.quote_table_name(table)
        quoted_column = connection.quote_column_name(column.name)
        execute "UPDATE #{quoted_table} SET #{quoted_column} = 1 WHERE #{quoted_column} = 't'"
        execute "UPDATE #{quoted_table} SET #{quoted_column} = 0 WHERE #{quoted_column} = 'f'"
      end
    end
  end

  def down
    # Both representations can be read by Rails 5.2; retain normalized values.
  end
end
