module HanaRecord
  class Base
    class << self
      def all
        results = []
        DB.execute("select * from #{@@table_name}") do |row|
          results << convert_row_to_model(row)
        end
        results
      end

      def find(id)
        results = []
        DB.execute("select * from #{@@table_name} where #{@@primary_key[:name]} = ?", id) do |row|
          results << convert_row_to_model(row)
        end
        results.first
      end

      def where(hash)
        results = []
        DB.execute("select * from #{@@table_name} where #{key_value_pairs_for_where hash}") do |row|
          results << convert_row_to_model(row)
        end
        results
      end

      def key_value_pairs_for_where(hash)
        hash.select do |key, value|
          attributes.include? key
        end.map do |key, value|
          "#{key} = '#{value}'"
        end.join(" and ")
      end

      def method_missing(method_sym, *args)
        method_name = method_sym.to_s
        return super unless /^find_by_(?<keys>.*)/ =~ method_name
        keys = keys.split("_and_")
        key_value_pair = keys.zip(args)
        find_by key_value_pair
      end

      def find_by(hash)
        results = []
        DB.execute("select * from #{@@table_name} where #{find_by_values hash}") do |row|
          results << convert_row_to_model(row)
        end
        results
      end

      def find_by_values(hash)
        query_collection = []
        hash.each do |key, value|
          query_collection << "#{key} = '#{value}'"
        end
        query_collection.join (' and ')
      end
    end
  end
end