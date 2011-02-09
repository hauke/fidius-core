require File.join(File.dirname(__FILE__), '..', '..','lib', 'fidius')

h = FIDIUS::Asset::Host.new("marie", "134.102.201.101")
scan = FIDIUS::Action::Scan::PortScan.new(h)
target = scan.execute

p target.get_services_as_bit_vector
