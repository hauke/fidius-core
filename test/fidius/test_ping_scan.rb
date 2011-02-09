require File.join(File.dirname(__FILE__), '..', '..','lib', 'fidius')

h = "127.0.0.0/29"
scan = FIDIUS::Action::Scan::PingScan.new(h)
hosts = scan.execute
i = 0
hosts.each do |host|
  h = FIDIUS::Asset::Host.new("host#{i}", host)
  scan = FIDIUS::Action::Scan::PortScan.new(h)
  target = scan.execute
  p "The Services: #{target.get_services_as_bit_vector}"
  i += 1
end
