require 'test_helper_fidius'
require 'test_helper_function'

class PortScanTest < FIDIUS::Test
  def test_port_scan
    h = FIDIUS::Asset::Host.find_or_create_by_ip "192.168.56.103"
    scan = FIDIUS::Action::Scan::PortScan.new(h.interfaces[0])
    target = scan.execute

    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.103"
    assert_equal "Windows", h.os_name
    vector   = target.get_services_as_bit_vector
    expected = [0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0]
    assert_equal expected, vector
  end
  
  def test_port_scan_and_db
    h = FIDIUS::Asset::Host.find_or_create_by_ip "192.168.56.103"
    scan = FIDIUS::Action::Scan::PortScan.new(h.interfaces[0])
    target = scan.execute
    h = FIDIUS::Asset::Host.find_or_create_by_ip "192.168.56.102"
    h.find_or_create_by_ip "192.168.56.101"
    scan = FIDIUS::Action::Scan::PortScan.new(h.interfaces[0])
    target = scan.execute
    scan = FIDIUS::Action::Scan::PortScan.new(h.interfaces[1])
    target = scan.execute


#    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.101" #TODO: why does this not work?
    
    assert_equal 2, h.interfaces.size
    assert_equal "192.168.56.102", h.interfaces[0].ip
    vector   = h.interfaces[0].get_services_as_bit_vector
    expected = [0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0]
    assert_equal expected.to_s, vector.to_s

    assert_equal "192.168.56.101", h.interfaces[1].ip
    vector   = h.interfaces[1].get_services_as_bit_vector
    expected = [0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]
    assert_equal expected.to_s, vector.to_s
  end

end
