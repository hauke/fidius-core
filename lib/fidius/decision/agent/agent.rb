## XXX: Hm. Should this be FIDIUS::Decision::Agent?? DKOHL: I am thinking about it :D
module FIDIUS
  module MachineLearning
    
    class Agent
      include Containers

      def initialize 
        # dimension = |known_services|; 8 layers
        @predictor = Predictor.new(FIDIUS::MachineLearning::known_services.size, 8)
        @open_list = PriorityQueue.new
        @current = nil
      end

      def add(interface)
        prediction = @predictor.predict(interface.get_services_as_bit_vector)
        @open_list.push(interface, prediction)
      end

      # returns the next host 
      # if there is no host in the priority queue
      # it returns the last one
      def next
        cur = @open_list.pop
        if cur == nil
          return @current
        end
        @current = cur
      end
      
      # Call for next host to exploit
      def decision neighbours # list of hosts
        neighbours.each do |n|
          n.interfaces.each do |i|
            if i.services == nil
              scan =  FIDIUS::Action::Scan::PortScan.new(i)
              scan.execute
            end

            # n.services: x_1 ... x_n with x_i in {0, 1}
            # 0: closed port
            # 1: open port
            prediction = @predictor.predict(i.get_services_as_bit_vector)
            prediction = prediction
            @open_list.push(i, prediction)
          end
        end
        return @open_list.pop
      end
      
      # call with array of instances for training and #operations
      def train instances, iterations
        instances.each do |inst|
          inst.host.interfaces.each do |i|
            @predictor.add_instance(i.get_services_as_bit_vector, inst.rating)
          end
        end
        iterations.times do
          @predictor.train
        end
      end
      
      def reward instance, iterations 
        instance.host.interfaces.each do |i|
          @predictor.add_instance(i.get_services_as_bit_vector, instance.rating)
        end
        iterations.times do
          @predictor.train
        end
      end

    end # class Agent
  end # module MachineLearning
end # module FIDIUS
