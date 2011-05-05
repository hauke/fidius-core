require 'ai4r'

module FIDIUS
  module MachineLearning
    class Predictor
      include Ai4r

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

    end # class Predictor
  end # module MachineLearning
end # module FIDIUS

