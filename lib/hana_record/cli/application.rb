require "thor"
require "time"
require_relative "generators/migrate"
require_relative "generators/model"
require_relative "generators/g"

module HanaRecord
  module CLI
    class Application < Thor
      register HanaRecord::CLI::G, 'g', 'g [model, migration]', 'Executes a multi-step subtask'
      register HanaRecord::CLI::Migrate, 'migrate', 'migrate', 'Executes a multi-step subtask'
    end
  end
end