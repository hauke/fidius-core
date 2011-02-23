require File.join File.expand_path(File.dirname __FILE__), '..', '..', 'lib', 'fidius'

def test_host
  h = FIDIUS::Asset::Host.create(:name => "KEEEEEKS", :ip => "192.168.0.1")
  h.services << FIDIUS::Service.new(:name => "ssh",    :port => 22,   :proto => "tcp")
  h.services << FIDIUS::Service.new(:name => "vnc",    :port => 5900, :proto => "tcp")
  h.services << FIDIUS::Service.new(:name => "smtp",   :port => 25,   :proto => "tcp")
  h.services << FIDIUS::Service.new(:name => "domain", :port => 53,   :proto => "udp")
  h.save
  p h.get_services_as_bit_vector
end

test_host
