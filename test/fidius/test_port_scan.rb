require 'test_fidius'

class PortScanTest < FIDIUS::Test
  def test_port_scan
    h = FIDIUS::Asset::Host.create(:name => "marie", :ip => "134.102.201.101")
    scan = FIDIUS::Action::Scan::PortScan.new(h)
    target = scan.execute

    vector   = target.get_services_as_bit_vector
    expected = []
    assert_equal expected, vector
  end
end
