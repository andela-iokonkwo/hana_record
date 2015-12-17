module HanaRecord
  module CLI
    class Model < Thor::Group
      include Thor::Actions

      # Define arguments and options
      argument :name
      argument :model, optional: false, type: :hash

      def self.source_root
        File.dirname(__FILE__)
      end

      def create_model_file
        template("templates/model.tt", "app/models/#{name}.rb")
      end

      def create_migration_file
        migration_name = "Create#{name.capitalize}s"
        migration_file_name = "#{(Time.now.to_f * 1000).to_i}_#{migration_name.to_snake_case}"
        template("templates/model_migration.tt", "db/migrations/#{migration_file_name}.rb")
      end
    end
  end
end