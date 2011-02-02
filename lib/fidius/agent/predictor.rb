module FIDIUS

module MachineLearning
  include Ai4r

  NODES_PER_LAYER = 10
  OUT = 1
  
  def self.known_services
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
  end

  class Predictor

    # dim: #known_services, num_layers: user specified (10)
    def initialize dim, num_layers
      @training_set = []
      @labels = []
      setup(dim, num_layers)       
    end

    #def initialize training_set, labels, num_layers
    #  @training_set = training_set
    #  @labels = labels
    #  setup(training_set[0].size, num_layers)    
    #end

    def train
      @training_set.size.times do |i|
        @ann.train(@training_set[i], @labels[i])
      end
    end
  
    def add_instance(example, label) 
      @training_set << example
      @labels << label
    end
    
    def predict(example)
      @ann.eval(example)
    end

private
    def setup dim, num_layers
      @ann_topology = []
      @ann_topology << dim
      num_layers.times do |i|
        @ann_topology << NODES_PER_LAYER
      end
      @ann_topology << OUT
      @ann = NeuralNetwork::Backpropagation.new(@ann_topology)
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
end

end


