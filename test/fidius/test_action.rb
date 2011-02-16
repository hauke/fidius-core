require File.join File.expand_path(File.dirname __FILE__), '..', '..', 'lib', 'fidius'
require 'test/unit/testcase.rb'
FIDIUS::Action.new

class ActionTest < Test::Unit::TestCase
  def test_truth
    assert true
  end
end
