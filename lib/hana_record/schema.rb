require "sqlite3"
module HanaRecord
  class Schema

    DB = SQLite3::Database.new("db/data.db")

    class << self
      def define(&block)
        table = Table.new
        table.instance_eval(&block)
        Migrations.run_all table.queries
      end

      def generate_schema
        schema = generate_tables
        schema << generate_index
      end

      def generate_tables
        table_record = ""
        tables = DB.execute "select name from sqlite_master where type = 'table'"
        tables.each do |table|
          table = table[0]
          next if [:sqlite_sequence, :databas_migration].include?(table.to_sym)
          table_record << "\tcreate_table :#{table} do |t| \n"
          table_info = DB.execute "pragma table_info(#{table})"
          # ['cid', 'name', 'type', 'not null', 'pk']
          table_info.each do |column|
            next if column[5] == 1
            default = column[4] ? " default: #{column[4]}," : ''
            null = " null: false" if column[3] == 1
            column_record = "\t\tt.#{column[2]} :#{column[1]},#{default}#{null}"
            column_record = column_record[0..-2] if column_record[-1] == ","
            table_record << column_record + "\n"
          end
          table_record << "\tend\n"
        end
        table_record
      end

      def generate_index
        index_record = ""
        indexes = DB.execute "select name, tbl_name from sqlite_master where type = 'index'"
        indexes.each do |index|
          index_name = index[0]
          table_name = index[1]
          index_info = DB.execute "pragma index_info(#{index_name})"
          column = index_info[0][2]
          index_record << "\tadd_index :#{table_name}, :#{column}, name: :#{index_name}\n"
        end
        index_record
      end
    end
  end
end