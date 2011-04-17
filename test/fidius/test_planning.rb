require 'test_unit_fidius'

class PlanningTest < FIDIUS::Test
  
  def test_plan
    # Host set
    h1 = FIDIUS::Asset::Host.create()
    h2 = FIDIUS::Asset::Host.create()
    h3 = FIDIUS::Asset::Host.create()
    h4 = FIDIUS::Asset::Host.create()
    h5 = FIDIUS::Asset::Host.create()

    i1 = FIDIUS::Asset::Interface.create()
    i1.ip = "192.168.0.1"
    h1.interfaces << i1
    i2 = FIDIUS::Asset::Interface.create()
    i2.ip = "192.168.0.2"
    h2.interfaces << i2
    i3 = FIDIUS::Asset::Interface.create()
    i3.ip = "192.168.0.3"
    h3.interfaces << i3
    i4 = FIDIUS::Asset::Interface.create()
    i4.ip = "192.0.0.1"
    h4.interfaces << i4
    i5 = FIDIUS::Asset::Interface.create()
    i5.ip = "192.0.0.1"
    h5.interfaces << i5

    # setup known services
    services = []
    services << FIDIUS::Service.create(:name => "ssh", :port => 22, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "vnc", :port => 5900, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "smtp", :port => 25, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "domain", :port => 53, :proto => "udp")
    services << FIDIUS::Service.create(:name => "mysql", :port => 3306, :proto => "tcp")
    
    #Create plan
    planner = FIDIUS::Planner.new    
    planner.hosts = [h1,h2,h3,h4,h5]
    planner.plan(services, h1, h5)
    
  end

end        

