require 'test_helper_fidius'
require 'test_helper_function'

# Action is a model, so this will not work anymore...
#   FIDIUS::Action.new

class ActionTest < FIDIUS::Test
  def test_truth
    assert true
  end
end
