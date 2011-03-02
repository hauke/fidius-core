require 'test_fidius'

class PlanningTest < FIDIUS::Test
  
  def test_plan
    # Host set
    h1 = FIDIUS::Asset::Host.create(:name => "099", :ip => "134.102.201.105")
    h2 = FIDIUS::Asset::Host.create(:name => "101", :ip => "134.102.201.104")
    h3 = FIDIUS::Asset::Host.create(:name => "101", :ip => "134.102.201.101")
    h4 = FIDIUS::Asset::Host.create(:name => "102", :ip => "134.102.201.102")
    h5 = FIDIUS::Asset::Host.create(:name => "103", :ip => "134.102.201.103")
    
    # get services
    services = FIDIUS::MachineLearning.known_services
    
    # Create plan
    planner = FIDIUS::Planner.new    
    planner.hosts = [h1,h2,h3,h4,h5]
    planner.plan(services, h1, h5)
  end

end        

