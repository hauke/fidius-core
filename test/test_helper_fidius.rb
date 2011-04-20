#require 'rubygems' #if RUBY_VERSION < '1.9'
require 'fidius'

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
