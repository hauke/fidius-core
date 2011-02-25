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
