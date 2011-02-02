require File.join(File.dirname(__FILE__), '..', '..', 'fidius')

module FIDIUS
include FIDIUS::Action::Scan

module MachineLearning
  include Containers

  class Instance
    
    attr_accessor :host, :value

    def initialize host, value
      @host = host
      @value = value
    end

  end

  class Agent
  
    def initialize 
      # dimension = |known_services|; 8 layers
      @predictor = Predictor.new(MachineLearning::known_services().size, 8)
      @open_list = PriorityQueue.new
    end

    # Call for next host to exploit
    def decision neighbours # list of hosts
      neighbours.each do |n|
        if n == nil
          scan =  PortScan.new(n, "21-4000")
          scan.execute
        end

        # n.services: x_1 ... x_n with x_i in {0, 1}
        # 0: closed port
        # 1: open port
        prediction = @predictor.predict(n.get_services_as_bit_vector)
        @open_list.push(n, prediction)
      end
      return @open_list.pop
    end
    
    # call with array of instances for training and #operations
    def train instances, iterations
      @instances.each do |i|
        @predictor.add_instance(i.host.get_services_as_bit_vector, i.value)
      end
      iterations.times do
        @predictor.train
      end
    end
    
  end
end # modules MachineLearning
end # modules FIDIUS
