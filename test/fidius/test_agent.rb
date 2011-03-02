require 'test_fidius'
 
class AgentTest < FIDIUS::Test
  include FIDIUS::MachineLearning
  
  def test_agent
    # Training set
    h1 = FIDIUS::Asset::Host.create(:name => "KEEEEEKS", :ip => "")
    h1.services = []
    h1.services << FIDIUS::Service.create(:name => "ssh", :port => 22, :proto => "tcp")
    h1.services << FIDIUS::Service.create(:name => "vnc", :port => 5900, :proto => "tcp")
    h1.services << FIDIUS::Service.create(:name => "smtp", :port => 25, :proto => "tcp")
    h1.services << FIDIUS::Service.create(:name => "domain", :port => 53, :proto => "udp")
    inst = Instance.new(h1, 2)
    h2 = FIDIUS::Asset::Host.create(:name => "KEEEEEKS2", :ip => "")
    h2.services = []
    h2.services << FIDIUS::Service.create(:name => "ssh", :port => 22, :proto => "tcp")
    h2.services << FIDIUS::Service.create(:name => "vnc", :port => 5900, :proto => "tcp")
    h2.services << FIDIUS::Service.create(:name => "smtp", :port => 25, :proto => "tcp")
    h2.services << FIDIUS::Service.create(:name => "domain", :port => 53, :proto => "udp")
    inst2 = Instance.new(h2, 3)

    # Test set
    h3 = FIDIUS::Asset::Host.create(:name => "101", :ip => "134.102.201.101")
    h4 = FIDIUS::Asset::Host.create(:name => "102", :ip => "134.102.201.102")
    h5 = FIDIUS::Asset::Host.create(:name => "103", :ip => "134.102.201.103")

    # Train agent
    agent = Agent.new
    agent.train([inst, inst2], 100)

    # Choose next
    dec = agent.decision([h3,h4,h5])
    assert_equal "134.102.201.101", dec.ip
    assert_equal "101", dec.name
  end
end
