require_relative "base/read_queries"
require_relative "base/write_queries"

module HanaRecord
  class Base
    DB = SQLite3::Database.new("db/data.db")
    DB.results_as_hash = true
    class << self
      def inherited(subclass)
        subclass.generate_attributes
      end

      def attributes
        @@attributes ||= []
      end

      def generate_attributes
        @@table_name = "#{self.to_s.downcase}s"
        table_info = DB.execute "pragma table_info(#{@@table_name})"
          # ['cid', 'name', 'type', 'not null', 'pk']
        table_info.each do |column|
          column_name = column[1]
          @@primary_key = column_name if column[5] == 1
          attributes << column_name
          define_getters_and_setters_for column_name
        end
      end

      def define_getters_and_setters_for(column_name)
        define_method(column_name) do
          instance_variable_get("@#{column_name}")
        end

        define_method("#{column_name}=") do |value|
          instance_variable_set("@#{column_name}", value)
        end
      end


      def convert_row_to_model(row)
        result = self.new
        attributes.each do |attribute|
          result.instance_variable_set("@#{attribute}", row["#{attribute}"])
        end
        result
      end
    end
  end
end