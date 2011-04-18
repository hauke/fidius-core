require 'test_helper_fidius'
require 'test_helper_function'

class PortScanTest < FIDIUS::Test
  def test_port_scan
    FIDIUS::Action::Scan::NmapScan.filename File.join(File.expand_path(File.dirname(__FILE__)), 'data', 'nmap-port-scan.xml')
    h = FIDIUS::Asset::Host.find_or_create_by_ip "192.168.56.3"
    scan = FIDIUS::Action::Scan::PortScan.new(h.interfaces[0])
    target = scan.execute

    assert_equal "Windows", h.os_name
    vector   = target.get_services_as_bit_vector
    expected = [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]
    assert_equal expected, vector
  end
  
  def test_port_scan_and_db
    FIDIUS::Action::Scan::NmapScan.filename File.join(File.expand_path(File.dirname(__FILE__)), 'data', 'nmap-port-scan.xml')
    h = FIDIUS::Asset::Host.find_or_create_by_ip "192.168.56.3"
    scan = FIDIUS::Action::Scan::PortScan.new(h.interfaces[0])
    target = scan.execute
    h = FIDIUS::Asset::Host.find_or_create_by_ip "192.168.56.2"
    h.find_or_create_by_ip "192.168.56.1"
    scan = FIDIUS::Action::Scan::PortScan.new(h.interfaces[0])
    target = scan.execute
    scan = FIDIUS::Action::Scan::PortScan.new(h.interfaces[1])
    target = scan.execute


#    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.1" #TODO: why does this not work?
    vector   = h.interfaces[0].get_services_as_bit_vector
    expected = [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]
    assert_equal expected, vector

    vector   = h.interfaces[1].get_services_as_bit_vector
    expected = [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]
    assert_equal expected, vector
  end

end
