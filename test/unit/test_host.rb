require 'test_helper_fidius'
class HostTest < FIDIUS::Test
  
  def setup
    super
    @ip = "192.168.177.2"
    @mac = "0a:00:27:00:00:02"
    @ipv6 = '2001:0db8:85a3:08d3:1319:8a2e:0370:7347/64'
    @host1 = FIDIUS::Asset::Host.find_or_create_by_ip_and_mac @ip , @mac
    @host2 = FIDIUS::Asset::Host.find_or_create_by_ip @ipv6
  end
  def teardown  
    @host1.delete
    @host2.delete
    super
  end
  
  def test_create_host_by_ip_and_mac
    ip = "192.168.177.1"
    mac = "0a:00:27:00:00:00"
    created_host = FIDIUS::Asset::Host.find_or_create_by_ip_and_mac ip, mac
    inter = created_host.find_by_ip ip
    assert_equal inter.ip, ip
    assert_equal inter.mac, mac
    created_host.delete
    inter.delete
  end
  
  def test_create_host_by_ip
    ip = "192.168.177.1"
    created_host = FIDIUS::Asset::Host.find_or_create_by_ip ip
    inter = created_host.find_by_ip ip
    assert_equal inter.ip, ip
    created_host.delete
    inter.delete
  end
  
  def test_find_host_by_ip
    found_host = FIDIUS::Asset::Host.find_by_ip @ip
    assert_equal found_host, @host1
  end
  
  def test_find_interface_by_ip
    inter = @host1.find_by_ip @ip
    assert_equal inter.ip, @ip
    assert_equal nil, @host1.find_by_ip(@mac)
  end
  
  def test_find_interface_by_ip_and_mac
    inter = @host1.find_by_ip_and_mac @ip, @mac
    assert_equal inter.ip, @ip
    assert_equal inter.mac, @mac
    assert_equal nil, @host1.find_by_ip_and_mac(@ip, "")
  end
   
  def test_find_or_create_interface_by_ip
    new_ip = "192.168.177.7"
    inter = @host1.find_or_create_by_ip new_ip
    assert_equal inter.ip, new_ip
  end
  
  def test_find_or_create_interface_by_ip_and_mac
    new_ip = "192.168.177.7"
    new_mac = "0a:00:27:00:00:03"
    inter = @host1.find_or_create_by_ip_and_mac new_ip, new_mac
    assert_equal inter.ip, new_ip
    assert_equal inter.mac, new_mac
  end
  
  def test_host_is_exploited
    assert_equal false, @host1.exploited?
  end
  
#  def test_host_is_reachable
#    @host1.reachable?
#  end
   def test_host_subnets
     subnets = @host1.subnets
     assert_equal 1, subnets.length
     assert_equal true, subnets[0].ip_range.include?(@ip)
     subnets2 = @host2.subnets
     assert_equal 1, subnets2.length
     assert_equal true, subnets2[0].ip_range.include?(@ipv6)
   end
end
