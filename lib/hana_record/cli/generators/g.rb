require "thor"
require "time"
module HanaRecord
  module CLI
    class G < Thor
      register HanaRecord::CLI::Model, 'model', 'model [model_name, attributes_hash]', 'Executes a multi-step subtask'
    end
  end
end