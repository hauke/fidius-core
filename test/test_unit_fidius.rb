require 'simplecov'
  SimpleCov.start
require 'fidius'
require 'mock/msf'
require 'mock/fidius'
gem 'test-unit'
require 'test/unit'

module FIDIUS
  class Test < Test::Unit::TestCase
    def setup
      FIDIUS.connect_db
      FIDIUS::Action::Msf.instance.start  if ENV['ENV'] == "test"
    end
    
    def teardown
      FIDIUS::Action::Msf.instance.stop  if ENV['ENV'] == "test"
      FIDIUS.disconnect_db
    end
  end
end
