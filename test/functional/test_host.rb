require 'test_helper_fidius'
require 'test_helper_function'

class HostTest < FIDIUS::Test
  def test_host_bit_vector
    h = FIDIUS::Asset::Host.find_or_create_by_ip '192.168.0.2'
    inter = h.find_or_create_by_ip "192.168.0.2"
    inter.services << FIDIUS::Service.new(:name => "ssh",    :port => 22,   :proto => "tcp")
    inter.services << FIDIUS::Service.new(:name => "vnc",    :port => 5900, :proto => "tcp")
    inter.services << FIDIUS::Service.new(:name => "smtp",   :port => 25,   :proto => "tcp")
    inter.services << FIDIUS::Service.new(:name => "domain", :port => 53,   :proto => "udp")
    inter.save

    vector = inter.get_services_as_bit_vector

    expected = [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    assert_equal expected, vector
  end
end
