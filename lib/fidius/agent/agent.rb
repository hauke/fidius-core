module FIDIUS

module MachineLearning
  include Containers
  include Action::Scan

  class Agent
  
    def initialize predictor
      @predictor = predictor
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
    
    def reward services, real_value
      @predictor.add_instance(services, real_value)
      @predictor.train
    end
  end
end
