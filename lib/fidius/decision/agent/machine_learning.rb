module FIDIUS
  include FIDIUS::Action::Scan
  
  module MachineLearning
    include Containers
    include Ai4r

    NODES_PER_LAYER = 10
    OUT = 1
    
    self.autoload :Agent,     'fidius/decision/agent/agent'
    self.autoload :Predictor, 'fidius/decision/agent/predictor'

    def self.agent
      @@AGENT ||= Agent.new()
    end

    def self.known_services
      @@services ||= initialize_services
    end
      
    def self.initialize_services
      services = []
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
      services
    end

    class Instance
      attr_accessor :host, :value

      def initialize host, value
        @host = host
        @value = [value]
      end
    end

    def str2example lin
      example = []
      str = line.split(",")
      str.each do |s|
        example << s.to_i
      end
      return example
    end
    
  end # module MachineLearning
end # module FIDIUS
