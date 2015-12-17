module HanaRecord
  module CLI
    class Migrate < Thor::Group
      include Thor::Actions

      class_option :direction, type: :string, default: 'up' , required: true, aliases: "-d"
      class_option :version, type: :numeric , required: false, aliases: "-v"
      class_option :step, type: :numeric , required: false, aliases: "-s"


      def self.source_root
        File.dirname(__FILE__)
      end

      def create_schema_file
        HanaRecord::Migrations.send("migrate_#{options[:direction]}", options)
        content = HanaRecord::Schema.generate_schema
        template("templates/schema.tt", "db/schema.rb", { content: content })
      end
    end
  end
end