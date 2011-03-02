## XXX: Hm. Should this be FIDIUS::Decision::Agent??

module FIDIUS
  module MachineLearning
    
    def self.agent()
      @@AGENT ||= Agent.new()
    end

    class Agent
      include Containers

      def initialize 
        # dimension = |known_services|; 8 layers
        @predictor = Predictor.new(FIDIUS::MachineLearning::known_services.size, 8)
        @open_list = PriorityQueue.new
      end

      def add(host)
        prediction = @predictor.predict(n.get_services_as_bit_vector)
        @open_list.push(n, prediction)
      end
      
      def next
        @open_list.pop
      end
      
      # Call for next host to exploit
      def decision neighbours # list of hosts
        neighbours.each do |n|
          if n.services == nil
            scan =  FIDIUS::Action::Scan::PortScan.new(n)
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
        instances.each do |i|
          @predictor.add_instance(i.host.get_services_as_bit_vector, i.value)
        end
        iterations.times do
          @predictor.train
        end
      end
      
      def reward instance, iterations 
        @predictor.add_instance(i.host.get_services_as_bit_vector, i.value)
        iterations.times do
          @predictor.train
        end
      end

    end # class Agent
  end # module MachineLearning
end # module FIDIUS
