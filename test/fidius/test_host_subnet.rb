require 'test_fidius'
require 'ipaddr'

class HostSubnetTest < FIDIUS::Test
  def test_host_subnet
    h = FIDIUS::Asset::Host.create()
    i1 = FIDIUS::Asset::Interface.create(:ip => '192.168.0.1')
    i2 = FIDIUS::Asset::Interface.create(:ip => '2001:0db8:85a3:08d3:1319:8a2e:0370:7347/64')
    h.interfaces << i1
    h.interfaces << i2
    
    subnets = [IPAddr.new("192.168.0.0/24"),IPAddr.new("2001:0db8:85a3:08d3::/64")]
    h.subnets.each do |sub|
      assert(subnets.include? sub.ip_range)
    end
  end
end
