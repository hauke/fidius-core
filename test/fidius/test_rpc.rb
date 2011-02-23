require 'test_fidius'

class RPCTest < FIDIUS::Test
  def test_exploit
    assert FIDIUS::Action::Exploit::Exploit.new
  end
end
