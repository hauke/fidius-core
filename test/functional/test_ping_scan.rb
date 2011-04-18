require 'test_helper_fidius'
require 'test_helper_function'

class PingScanTest < FIDIUS::Test
  def test_ping_scan
    FIDIUS::Action::Scan::NmapScan.filename File.join(File.expand_path(File.dirname(__FILE__)), 'data', 'nmap-ping-scan.xml')
    h = "192.168.56.0/24"
    scan = FIDIUS::Action::Scan::PingScan.new(h)
    hosts = scan.execute
    assert_equal 3, hosts.size
    assert_equal "192.168.56.1", hosts[0]
    assert_equal "192.168.56.2", hosts[1]
    assert_equal "192.168.56.3", hosts[2]
    hosts.each do |host|
      h = FIDIUS::Asset::Host.find_or_create_by_ip(host)
      FIDIUS::Action::Scan::NmapScan.filename File.join(File.expand_path(File.dirname(__FILE__)), 'data', 'nmap-port-scan.xml')
      scan = FIDIUS::Action::Scan::PortScan.new(h.interfaces[0])
      target = scan.execute
    end
  end
end
