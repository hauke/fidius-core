require 'test_fidius'

class PortScanTest < FIDIUS::Test
  def test_port_scan
    h = FIDIUS::Asset::Host.find_or_create_by_ip "134.102.201.101"
    inter = h.find_or_create_by_ip "134.102.201.101"
    scan = FIDIUS::Action::Scan::PortScan.new(inter)
    target = scan.execute

    vector   = target.get_services_as_bit_vector
    expected = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    assert_equal expected, vector
  end
end
