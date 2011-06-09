#require 'rubygems' #if RUBY_VERSION < '1.9'
require 'fidius'
require 'helper/fidius_db_helper'
require 'simplecov'
require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
require 'test/unit'

module FIDIUS
  class Test < Test::Unit::TestCase
    def setup
      FIDIUS.connect_db
      
    end
    
    def teardown
      FIDIUS.disconnect_db
    end
  end
end

def prepare_test_db
  wd = Dir.pwd
  cfg_d = File.join wd, "config"
  ENV['ENV'] = "test"
#  #ActiveRecord::Migration.verbose = false
  db_helper = FIDIUS::DbHelper.new cfg_d, wd
  db_helper.drop_database  rescue nil
  db_helper.create_database
  db_helper.with_db {
    Dir.chdir(wd)
    ActiveRecord::Migrator.migrate("#{cfg_d}/sql", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  }
end

def check_vms
  @example = YAML.load_file File.expand_path("../../config/fidius.yml.example", __FILE__)
  if FIDIUS.config[:tests]
      @example[:tests].each_pair { |key, pair|
      unless FIDIUS.config[:tests][key]
        puts "The Following Key isn't defined in the config_file: #{key}"
      end
    }
  else
    puts "No Test-Section defined in config_file"
  end
end

prepare_test_db
check_vms
