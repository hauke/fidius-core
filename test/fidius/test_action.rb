require 'test_fidius'

# Action is a model, so this will not work anymore...
#   FIDIUS::Action.new

class ActionTest < FIDIUS::Test
  def test_truth
    assert true
  end
end
