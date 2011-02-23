require 'test_fidius'

class PingScanTest < FIDIUS::Test
  def test_ping_scan
    h = "127.0.0.0/29"
    scan = FIDIUS::Action::Scan::PingScan.new(h)
    hosts = scan.execute
    i = 0
    hosts.each do |host|
      h = FIDIUS::Asset::Host.create(:name => "host#{i}", :ip => host)
      scan = FIDIUS::Action::Scan::PortScan.new(h)
      target = scan.execute
      p "The Services: #{target.get_services_as_bit_vector}"
      i += 1
    end
    assert true
  end
end
