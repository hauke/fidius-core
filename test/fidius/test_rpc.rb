require 'test_fidius'

class RPCTest < FIDIUS::Test
  include FIDIUS::Action::Exploit
  
  def test_exploit
    assert Exploit.new
  end
end
