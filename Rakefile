require 'rake/testtask'
require 'active_record'
require 'logger'

$WD = Dir.pwd

Rake::TestTask.new do |t|
  Dir.chdir("test/fidius")
  t.libs << "test"
  t.test_files = FileList['test_*.rb']
  t.verbose = true
end

def get_env
  ENV["ENV"] || "development" 
end

def connection_data
  Dir.chdir($WD)
  @connection_data ||= YAML.load_file('lib/data/database.yml')[get_env]
end

def with_db &block
  ActiveRecord::Base.establish_connection(connection_data)
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger.level = Logger::WARN
  yield connection_data
  ActiveRecord::Base.connection.disconnect!
end

namespace :db do
  desc "Migrates the database."
  task :migrate do
    with_db do
      Dir.chdir($WD)
      ActiveRecord::Migrator.migrate('lib/data/sql', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
  end

  desc "Creates the database."
  task :create do    
    with_db do |config|
      ActiveRecord::Base.connection.execute("CREATE DATABASE #{conn["config"]}")
    end
  end

  desc "Deletes the database."
  task :drop do 
    with_db do |config|
      ActiveRecord::Base.connection.execute("DROP DATABASE #{config["database"]}")
    end
  end
end
