require 'rake/testtask'
require 'active_record'

$WD = Dir.pwd

# getting config dir
$CFG_D = File.join $WD, "config"

Rake::TestTask.new do |t|
  Dir.chdir("test/fidius")
  t.libs << "test"
  t.test_files = FileList['test_*.rb']
  t.verbose = true
end
def get_env
  if ENV["ENV"].to_s.size <= 0
     env = "development" 
   else
     env = ENV["ENV"]
  end
  return env
end
def connection_data
  YAML::load(File.open("#{CFG_D}/database.yml"))[get_env]
end

def connect_to_db
  #connection_data = YAML::load(File.open("#{CFG_D}/database.yml))[ENV["DB"]]
  ActiveRecord::Base.establish_connection(connection_data)
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

namespace :test do
  task :test do
    puts "root directory: #{$WD}"
    puts "config directory: #{$CFG_D}"
  end
end

namespace :db do
  task :migrate do 
    connect_to_db
    Dir.chdir($WD)
    ActiveRecord::Migrator.migrate("#{CFG_D}/sql", ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end
  task :create do
    conn = connection_data
    conn.delete("database")
    ActiveRecord::Base.establish_connection(conn)
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.connection.execute("CREATE DATABASE #{connection_data.delete("database")}")
  end

  task :drop do 
    #connection_data = YAML::load(File.open('../../tmp/database.yml'))[ENV["DB"]]
    #db_name = connection_data['database']
    conn = connection_data
    conn.delete("database")
    ActiveRecord::Base.establish_connection(conn)
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.connection.execute("DROP DATABASE #{connection_data.delete("database")}")
  end
end
