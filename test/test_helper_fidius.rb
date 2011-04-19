require 'rubygems' if RUBY_VERSION < '1.9'
require 'simplecov'
require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
require 'fidius'
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
