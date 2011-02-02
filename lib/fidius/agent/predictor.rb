require 'rubygems'
require 'ai4r'

include Ai4r

module MachineLearning

  NODES_PER_LAYER = 10
  OUT = 1

  class Predictor

    def initialize dim, num_layers
      setup(dim, num_layers)       
    end

    def initialize training_set, labels, num_layers
      @training_set = training_set
      @labels = labels
      setup(training_set[0].size, num_layers)    
    end

    def train
      @training_set.size.times do |i|
        @ann.train(@training_set[i], @labels[i])
      end
    end
  
    def add_instance(example, label) 
      @training_set << example
      @labels << lable
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

  def str2example line
    example = []
    str = line.split(",")
    str.each do |s|
      example << s.to_i
    end
    return example
  end
end

# TEST
include MachineLearning

set = []
labels = []

fp = File.open("nmap.csv", "r")
while line = fp.gets
  set << str2example(line)
end
fp.close

fp = File.open("pred.csv", "r")
while line = fp.gets
   labels << [line.to_i]
end
fp.close

pred =  Predictor.new(set, labels, 2)
300.times do |i|
  pred.train
end

set.size.times do |x|
  puts "#{pred.predict(set[x])}" # "#{labels[x]}"
end
