# frozen_string_literal: true

require 'spec_helper'
require_relative '../../db/migrate/20260930000000_normalize_sqlite_booleans'

describe NormalizeSqliteBooleans do
  it 'converts legacy boolean values without changing integers or nulls' do
    connection = ActiveRecord::Base.connection
    skip 'Legacy t/f booleans are specific to SQLite' unless connection.adapter_name == 'SQLite'

    begin
      connection.create_table(:legacy_boolean_values) { |table| table.boolean :flag }
      connection.execute("INSERT INTO legacy_boolean_values (flag) VALUES ('t'), ('f'), (1), (0), (NULL)")
      described_class.new.migrate(:up)

      expect(connection.select_values('SELECT flag FROM legacy_boolean_values ORDER BY id')).to eq([1, 0, 1, 0, nil])
    ensure
      connection.drop_table(:legacy_boolean_values, if_exists: true)
    end
  end
end
