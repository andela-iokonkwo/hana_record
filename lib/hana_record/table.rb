module HanaRecord
  class Table
    def queries
      @queries ||= []
    end

    def create_table(table_name, &block)
      primary_key = generate_primary_key(table_name)
      table_columnns_query = block.call(Attributes.get)
      queries <<(<<-query)
          create table if not exists #{table_name}(
             #{primary_key} integer primary key  autoincrement not null ,
             #{table_columnns_query.join(', ')}
          )
        query
    end

    def generate_primary_key(table_name)
      table_name = table_name[0..-2] if table_name[-1] == "s"
      table_name + "_id"
    end

    def add_column(table_name, column_name, type, *args)
      column_definition = Attributes.new.send(type, column_name, *args)[0]
      queries <<(<<-query)
          alter table #{table_name}
            add column #{column_definition};
        query
    end

    def rename_table(table_name, new_table_name)
      queries <<(<<-query)
          alter table #{table_name}
            rename to #{new_table_name};
        query
    end

    def add_reference(table_name, foreign_table_name, type, *args)
      type = :integer unless type
      column = "#{foreign_table_name}_id"
      add_column table_name, column, type, *args
      add_index table_name, column
    end

    def drop_table(table_name)
      queries << "drop table if exists #{table_name}"
    end

    def add_index(table_name, columns, name: nil)
      columns = [columns] unless columns.kind_of?(Array)
      name = "index_#{table_name}_on_#{columns.join('_and_')}" unless name
      queries <<(<<-query)
          create index #{name}
            on #{table_name} (#{columns.join(', ')});
        query
    end
  end
end