module HanaRecord
  class Base

    def destroy
      DB.execute self.class.destroy_query, primary_key_value
    end

    def self.destroy(id)
      DB.execute destroy_query, id
    end

    def self.destroy_all
      DB.execute "delete from #{@@table_name}"
    end

    def self.destroy_query
      <<-query
        delete from #{@@table_name}
        where #{@@primary_key} = ?
      query
    end

    def primary_key_value
      send("#{@@primary_key}")
    end

    def save
      if primary_key_value
        DB.execute update_query, primary_key_value
        self.class.find(primary_key_value)
      else
        DB.execute insert_query, insert_values
        self.class.find(DB.last_insert_row_id)
      end
    end

    def insert_query
      <<-query
        insert into #{@@table_name}
        ( #{table_columes} )
        values
        ( #{insert_values_placeholder} )
      query
    end

    def update_query
      <<-query
          update #{@@table_name}
          set #{update_record_key_value_pairs}
          where #{@@primary_key} = ?
      query
    end

    def update_record_key_value_pairs
      attributes_without_primary_key.select do |attribute|
        !send(attribute).nil?
      end.map do |attribute|
        "#{attribute} = '#{send(attribute)}'"
      end.join(", ")
    end


    def table_columes
      attributes_without_primary_key.map do |attribute|
        attribute
      end.join(", ")
    end

    def attributes_without_primary_key
      attributes - [@@primary_key]
    end

    def insert_values_placeholder
      attributes_without_primary_key.map do |attribute|
        "?"
      end.join(", ")
    end

    def insert_values
      attributes_without_primary_key.map do |attribute|
        send("#{attribute}")
      end
    end
  end
end