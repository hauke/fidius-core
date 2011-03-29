require 'test_fidius'
 
class AgentTest < FIDIUS::Test
  include FIDIUS::MachineLearning
  
  def test_agent
    services << Service.create(:name => "ssh", :port => 22, :proto => "tcp")
    services << Service.create(:name => "vnc", :port => 5900, :proto => "tcp")
    services << Service.create(:name => "smtp", :port => 25, :proto => "tcp")
    services << Service.create(:name => "domain", :port => 53, :proto => "udp")
    services << Service.create(:name => "mysql", :port => 3306, :proto => "tcp")
    services << Service.create(:name => "http", :port => 80, :proto => "tcp")
    services << Service.create(:name => "netbios-ssn", :port => 139, :proto => "tcp")
    services << Service.create(:name => "netbios-ssn", :port => 139, :proto => "udp")
    services << Service.create(:name => "microsoft-ds", :port => 445, :proto => "tcp")
    services << Service.create(:name => "ftp", :port => 21, :proto => "tcp")
    services << Service.create(:name => "ipp", :port => 631, :proto => "tcp")
    services << Service.create(:name => "ipp", :port => 631, :proto => "udp")
    services << Service.create(:name => "afp", :port => 548, :proto => "tcp")
    services << Service.create(:name => "afp", :port => 548, :proto => "udp")
    services << Service.create(:name => "kerberos-sec", :port => 88, :proto => "tcp")
    services << Service.create(:name => "kerberos-sec", :port => 88, :proto => "udp")
    services << Service.create(:name => "https", :port => 443, :proto => "tcp")
    services << Service.create(:name => "svn", :port => 3690, :proto => "tcp")
    services << Service.create(:name => "aol", :port => 5190, :proto => "tcp")
    services << Service.create(:name => "http-proxy", :port => 1080, :proto => "tcp")
    services << Service.create(:name => "pop3", :port => 110, :proto => "tcp")
    services << Service.create(:name => "ldap", :port => 389, :proto => "tcp")
    services << Service.create(:name => "cvspserver", :port => 2401, :proto => "tcp")
    services << Service.create(:name => "imap", :port => 143, :proto => "tcp")
  
    # Training set
    h1 = FIDIUS::Asset::Host.create()
    i1 = FIDIUS::Asset::Interface.create()
    # i1.services = []
    i1.services << FIDIUS::Service.create(:name => "ssh", :port => 22, :proto => "tcp")
    i1.services << FIDIUS::Service.create(:name => "vnc", :port => 5900, :proto => "tcp")
    i1.services << FIDIUS::Service.create(:name => "smtp", :port => 25, :proto => "tcp")
    i1.services << FIDIUS::Service.create(:name => "domain", :port => 53, :proto => "udp")
    # h1.value = 2
    h1.interfaces << i1
    inst1 = Instance.new(h1,2)

    h2 = FIDIUS::Asset::Host.create()
    i2 = FIDIUS::Asset::Interface.create()
    # h2.services = []
    i2.services << FIDIUS::Service.create(:name => "ssh", :port => 22, :proto => "tcp")
    i2.services << FIDIUS::Service.create(:name => "vnc", :port => 5900, :proto => "tcp")
    i2.services << FIDIUS::Service.create(:name => "smtp", :port => 25, :proto => "tcp")
    i2.services << FIDIUS::Service.create(:name => "domain", :port => 53, :proto => "udp")
    # h2.value = 3
    h2.interfaces << i2
    inst2 = Instance.new(h2,5)

    # Test set
    h3 = FIDIUS::Asset::Host.create()
    i3 = FIDIUS::Asset::Interface.create(:ip => "134.102.201.101")
    h4 = FIDIUS::Asset::Host.create()
    i4 = FIDIUS::Asset::Interface.create(:ip => "134.102.201.102")
    h3.interfaces << i3
    h4.interfaces << i4
    # Train agent
    agent = Agent.new
    agent.train([inst1, inst2], 100)

    # Choose next
    dec = agent.decision([h3,h4])
    assert_equal "134.102.201.101", dec.ip
  end
end
