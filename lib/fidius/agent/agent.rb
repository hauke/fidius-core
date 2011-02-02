module FIDIUS

module MachineLearning
  include Containers
  class Agent
  
    def initialize predictor
      @predictor = predictor
      @open_list = PriorityQueue.new
    end

    def decision neighbours
      neighbours.each do |n|
        # n.services: x_1 ... x_n with x_i in {0, 1}
        # 0: closed port
        # 1: open port
        prediction = @predictor.predict(n.services)
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

end # FIDIUS
