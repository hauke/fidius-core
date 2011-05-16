require 'rubygems' if RUBY_VERSION < '1.9'
require 'rake/testtask'
require 'active_record'
require 'ci/reporter/rake/test_unit' # use this if you're using Test::Unit

$LOAD_PATH.unshift File.expand_path(File.dirname __FILE__)
require 'lib/fidius'
require 'lib/helper/fidius_db_helper'
require 'logger'

$WD = Dir.pwd
import File.join("#{$WD}","test","scenarios.rake")
# getting config dir
$CFG_D = File.join $WD, "config"
@db_helper = FIDIUS::DbHelper.new $CFG_D, $WD

namespace :debug do
  desc "Print out important directories."
  task :dirs do
    puts "root directory:   #{$WD}"
    puts "config directory: #{$CFG_D}"
    puts "load_path:\n\t#{$LOAD_PATH.join "\n\t"}"
  end
end

namespace :db do
  desc "Migrates the database."
  task :migrate do    
    @db_helper.with_db do
      Dir.chdir($WD)
      ActiveRecord::Migrator.migrate("#{$CFG_D}/sql", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
  end

  desc "Creates the database."
  task :create do
    @db_helper.create_database
  end

  desc "Deletes the database."
  task :drop do 
    @db_helper.drop_database
  end
end

begin
  require 'yard'

  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files = ['lib/**/*.rb']
    static_files = 'LICENSE'
    t.options += [
      '--title', 'FIDIUS Architecture',
      '--private',   # include private methods
      '--protected', # include protected methods
      '--files', static_files,
      '--readme', 'README.md',
      '--exclude', 'misc'
    ]
  end
rescue LoadError
  puts 'YARD not installed (gem install yard), http://yardoc.org'
end

def setup_test_enviorment
  ENV['ENV'] = "test"
  #ActiveRecord::Migration.verbose = false
  FIDIUS::DbHelper.drop_database(connection_data)
  FIDIUS::DbHelper.create_database(connection_data)
  with_db {
    Dir.chdir($WD)
    ActiveRecord::Migrator.migrate("#{$CFG_D}/sql", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  }
end

$UNIT = 'test/unit/test_*.rb'
$FUNCTIONAL = 'test/functional/test_*.rb'
$INTEGRATION = 'test/integration/test_*.rb'
def create_test_task name, files
   Rake::TestTask.new(name) do |t|
    t.libs << "test"
    t.test_files = (FileList[] << files)
    t.verbose = true
  end
end

task :test do 
  Rake::Task["test:all"].invoke
end

namespace :test do  
  create_test_task :unit, $UNIT
  create_test_task :functional, $FUNCTIONAL
  create_test_task :integration, $INTEGRATION
  create_test_task :all, [$UNIT, $FUNCTIONAL]
end

namespace :lab do
  namespace :create do
    task :virtualbox do
      lab_helper = FIDIUS::LabHelper.new
      lab_helper.create_lab_config "virtualbox"
    end
  end
end

