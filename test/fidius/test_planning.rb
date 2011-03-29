require 'test_fidius'

class PlanningTest < FIDIUS::Test
  
  def test_plan
    # Host set
    h1 = FIDIUS::Asset::Host.create()
    h2 = FIDIUS::Asset::Host.create()
    h3 = FIDIUS::Asset::Host.create()
    h4 = FIDIUS::Asset::Host.create()
    h5 = FIDIUS::Asset::Host.create()
     
    services = []
    services << FIDIUS::Service.create(:name => "ssh", :port => 22, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "vnc", :port => 5900, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "smtp", :port => 25, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "domain", :port => 53, :proto => "udp")
    services << FIDIUS::Service.create(:name => "mysql", :port => 3306, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "http", :port => 80, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "netbios-ssn", :port => 139, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "netbios-ssn", :port => 139, :proto => "udp")
    services << FIDIUS::Service.create(:name => "microsoft-ds", :port => 445, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "ftp", :port => 21, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "ipp", :port => 631, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "ipp", :port => 631, :proto => "udp")
    services << FIDIUS::Service.create(:name => "afp", :port => 548, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "afp", :port => 548, :proto => "udp")
    services << FIDIUS::Service.create(:name => "kerberos-sec", :port => 88, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "kerberos-sec", :port => 88, :proto => "udp")
    services << FIDIUS::Service.create(:name => "https", :port => 443, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "svn", :port => 3690, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "aol", :port => 5190, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "http-proxy", :port => 1080, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "pop3", :port => 110, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "ldap", :port => 389, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "cvspserver", :port => 2401, :proto => "tcp")
    services << FIDIUS::Service.create(:name => "imap", :port => 143, :proto => "tcp")
    
    #Create plan
    planner = FIDIUS::Planner.new    
    planner.hosts = [h1,h2,h3,h4,h5]
    planner.plan(services, h1, h5)
    
  end

end        

