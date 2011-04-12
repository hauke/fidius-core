require 'test_fidius'

class HostTest < FIDIUS::Test
  def test_host
    h = FIDIUS::Asset::Host.create(:name => "KEEEEEKS")
    inter = h.find_or_create_by_ip "192.168.0.1"
    inter.services << FIDIUS::Service.new(:name => "ssh",    :port => 22,   :proto => "tcp")
    inter.services << FIDIUS::Service.new(:name => "vnc",    :port => 5900, :proto => "tcp")
    inter.services << FIDIUS::Service.new(:name => "smtp",   :port => 25,   :proto => "tcp")
    inter.services << FIDIUS::Service.new(:name => "domain", :port => 53,   :proto => "udp")
    inter.save
   
    vector = inter.get_services_as_bit_vector
    expected = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    assert_equal expected, vector
  end
end
