require "sqlite3"
module HanaRecord
  class Migrations
    DB = SQLite3::Database.new("db/data.db")
    class << self

      def migrate_up(options)
        DB.execute("create table if not exists migrations (version integer not null)")
        migration_files_to_migrate_up.each do |migration_file|
          timestamp = execute_migration(migration_file, options[:direction])
          DB.execute("insert into migrations (version) values (#{timestamp})")
        end
      end

      def migrate_down(options)
        DB.execute("create table if not exists migrations (version integer not null)")
        migration_files_to_migrate_down(options[:step], options[:version]).each do |f|
          execute_migration f, options[:direction]
        end
        DB.execute("delete from migrations where version > ?", @version)
      end

      def execute_migration(file, direction)
        load "db/migrations/#{file}"
        /(?<timestamp>.\d+)_(?<migration>.*).rb/ =~ file
        class_to_migrate = migration.to_camel_case
        migration_class = Object.const_get(class_to_migrate)
        run_all migration_class.new.send(direction)
        timestamp
      end

      def migration_files_to_migrate_up
        migration_version = DB.execute("select version from migrations order by version desc limit 1")
        version = migration_version[0] || [0]
        directories = Dir.entries("db/migrations")
        puts directories.inspect
        migration_files version[0], directories
      end

      def migration_files_to_migrate_down(step, version)
          directories = Dir.entries("db/migrations")
          return migration_files(version, directories) if version
          migrations_files_by_step(step, directories)
      end

      def migrations_files_by_step(step, directories)
        step = step.to_i + 1
        rollback_point = directories[-step]
        /(?<version>.\d+)_*.rb/ =~ rollback_point
        migration_files directories, timestamp
      end

      def migration_files(version, directories)
        @version = version.to_i
        directories.select do |f|
          file_timestamp = f.split("_")[0].to_i
          file_timestamp > version.to_i
        end
      end

      def run_all(queries)
        queries.each do |query|
          DB.execute query
        end
      end
    end

    def initialize
      @table = Table.new
    end


    def respond_to_missing(method_name)
      @table.respond_to? method_name
    end

    def method_missing(method_name, *args, &block)
      return super unless @table.respond_to?(method_name)
      @table.send(method_name, *args, &block)
    end
  end
end