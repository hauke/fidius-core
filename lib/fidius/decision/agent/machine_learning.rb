module FIDIUS
  include FIDIUS::Action::Scan
  
  module MachineLearning
    include Containers
    include Ai4r

    NODES_PER_LAYER = 10
    OUT = 1
    
    def self.known_services
      @@services ||= initialize_services
    end
      
    def self.initialize_services
      services = []
      services << Service.new("ssh", 22, "tcp")
      services << Service.new("vnc", 5900, "tcp")
      services << Service.new("smtp", 25, "tcp")
      services << Service.new("domain", 53, "udp")
      services << Service.new("mysql", 3306, "tcp")
      services << Service.new("http", 80, "tcp")
      services << Service.new("netbios-ssn", 139, "tcp")
      services << Service.new("netbios-ssn", 139, "udp")
      services << Service.new("microsoft-ds", 445, "tcp")
      services << Service.new("ftp", 21, "tcp")
      services << Service.new("ipp", 631, "tcp")
      services << Service.new("ipp", 631, "udp")
      services << Service.new("afp", 548, "tcp")
      services << Service.new("afp", 548, "udp")
      services << Service.new("kerberos-sec", 88, "tcp")
      services << Service.new("kerberos-sec", 88, "udp")
      services << Service.new("https", 443, "tcp")
      services << Service.new("svn", 3690, "tcp")
      services << Service.new("aol", 5190, "tcp")
      services << Service.new("http-proxy", 1080, "tcp")
      services << Service.new("pop3", 110, "tcp")
      services << Service.new("ldap", 389, "tcp")
      services << Service.new("cvspserver", 2401, "tcp")
      services << Service.new("imap", 143, "tcp")
      services
    end

    self.autoload :Agent,     'fidius/decision/agent/agent'
    self.autoload :Predictor, 'fidius/decision/agent/predictor'

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
