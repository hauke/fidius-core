require 'rubygems' if RUBY_VERSION < '1.9'
require 'active_record'

module FIDIUS
  class DbHelper
    
    def initialize cfg_d, wd
      @cfg_d = cfg_d
      @wd = wd
    end
  
    def get_env
      ENV["ENV"] || "development" 
    end

    def connection_data
      Dir.chdir(@wd)
      @connection_data ||= YAML.load_file("#{@cfg_d}/fidius.yml")['databases'][get_env]
    end
  
    def with_db &block
      begin
        ActiveRecord::Base.establish_connection(connection_data)
        ActiveRecord::Base.logger = Logger.new(STDOUT)
        ActiveRecord::Base.logger.level = Logger::WARN
        yield connection_data
      rescue
        raise
      ensure
        ActiveRecord::Base.connection.disconnect!
      end
    end

    # copied and modified activerecord-3.0.4/lib/active_record/railties/database.rake
    def drop_database
      config = connection_data
      case config['adapter']
      when /mysql/
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.connection.drop_database config['database']
      when 'postgresql'
        ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
        ActiveRecord::Base.connection.drop_database config['database']
      end
    end

    # dito
    def create_database
      config = connection_data
      case config['adapter']
      when /mysql/
        require 'mysql'
        @charset   = ENV['CHARSET']   || 'utf8'
        @collation = ENV['COLLATION'] || 'utf8_unicode_ci'
        creation_options = {:charset => (config['charset'] || @charset), :collation => (config['collation'] || @collation)}
        error_class = config['adapter'] =~ /mysql2/ ? Mysql2::Error : Mysql::Error
        access_denied_error = 1045
        begin
          ActiveRecord::Base.establish_connection(config.merge('database' => nil))
          ActiveRecord::Base.connection.create_database(config['database'], creation_options)
          ActiveRecord::Base.establish_connection(config)
        rescue error_class => sqlerr
          if sqlerr.errno == access_denied_error
            print "#{sqlerr.error}. \nPlease provide the root password for your mysql installation\n>"
            root_password = $stdin.gets.strip
            grant_statement = "GRANT ALL PRIVILEGES ON #{config['database']}.* " \
              "TO '#{config['username']}'@'localhost' " \
              "IDENTIFIED BY '#{config['password']}' WITH GRANT OPTION;"
            ActiveRecord::Base.establish_connection(config.merge(
                'database' => nil, 'username' => 'root', 'password' => root_password))
            ActiveRecord::Base.connection.create_database(config['database'], creation_options)
            ActiveRecord::Base.connection.execute grant_statement
            ActiveRecord::Base.establish_connection(config)
          else
            $stderr.puts sqlerr.error
            $stderr.puts "Couldn't create database for #{config.inspect}, charset: #{config['charset'] || @charset}, collation: #{config['collation'] || @collation}"
            $stderr.puts "(if you set the charset manually, make sure you have a matching collation)" if config['charset']
          end
        end
      when 'postgresql'
        @encoding = config['encoding'] || ENV['CHARSET'] || 'utf8'
        begin
          ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
          ActiveRecord::Base.connection.create_database(config['database'], config.merge('encoding' => @encoding))
          ActiveRecord::Base.establish_connection(config)
        rescue Exception => e
          $stderr.puts e, *(e.backtrace)
          $stderr.puts "Couldn't create database for #{config.inspect}"
        end
      end
    end
    
  end
end
