
require File.join(File.dirname(__FILE__), '..', '..','lib', 'fidius')

def test_host
  h = FIDIUS::Asset::Host.new("KEEEEEKS")
  h.services = []
  h.services << FIDIUS::Service.new("ssh", 22, "tcp")
  h.services << FIDIUS::Service.new("vnc", 5900, "tcp")
  h.services << FIDIUS::Service.new("smtp", 25, "tcp")
  h.services << FIDIUS::Service.new("domain", 53, "udp")
  p h.get_services_as_bit_vector
end

test_host
