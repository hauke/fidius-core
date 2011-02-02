module FIDIUS

module MachineLearning
  include Containers
  include Action::Scan

  class Instance
    
    attr_acessor :host, :value

    def initialize host, value
      @host = host
      @value = value
    end

  end

  class Agent
  
    def initialize 
      # dimension = |known_services|; 8 layers
      @predictor = Predictor.new(known_services().size, 8)
      @open_list = PriorityQueue.new
    end

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
    
    def train instances
      @instances.each do |i|
        @predictor.add_instance(i.host.get_services_as_bit_vector, i.value)
      end
      @predictor.train
    end

  end
end
