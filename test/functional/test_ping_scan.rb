require 'test_helper_fidius'
require 'test_helper_function'

class PingScanTest < FIDIUS::Test
  def test_ping_scan_scanned_hosts
    h = "192.168.56.0/24"
    scan = FIDIUS::Action::Scan::PingScan.new(h)
    hosts = scan.execute
    assert_equal 4, hosts.size
    assert_equal "192.168.56.1", hosts[0]
    assert_equal "192.168.56.101", hosts[1]
    assert_equal "192.168.56.102", hosts[2]
    assert_equal "192.168.56.103", hosts[3]
    hosts.each do |host|
      h = FIDIUS::Asset::Host.find_or_create_by_ip(host)
      interface = h.interfaces[0] if h.interfaces[0].ip.include?("192.168.56")
      interface = h.interfaces[1] unless interface
      scan = FIDIUS::Action::Scan::PortScan.new(interface)
      target = scan.execute
    end
  end
end
