require "pry"
module HanaRecord
  class Attributes
    def self.get
      new
    end

    def query
      @query ||= []
    end

    def self.data_type_to_method_name_mapping
      {  string: :text,
        int: :integer,
        integer: :integer,
        boolean: :boolean,
        float: :real,
        datetime: :text
      }
    end

    data_type_to_method_name_mapping.each do |key, value|
      define_method(key) do |column, null: true, default: false|
        query << "#{column} #{value} #{null ? '':'not null'} #{get_default(default)}"
      end
    end

    def get_default(value)
      return '' unless value
      'DEFAULT ' + value.to_s
    end
  end
end