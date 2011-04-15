require 'simplecov'
  SimpleCov.start
require 'fidius'
require 'test/unit'


module FIDIUS
  class Test < Test::Unit::TestCase
    def setup
      FIDIUS.connect_db
      FIDIUS::Action::Msf.instance.start  if ENV['ENV'] == "test"
    end
    
    def teardown
      FIDIUS.disconnect_db
    end
  end
end
