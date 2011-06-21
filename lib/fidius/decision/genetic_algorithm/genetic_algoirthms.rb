# Tool will optimize a snort rule set 
#
# Customized from ai4r
module FIDIUS
  module GeneticAlgorithm
    class GeneticSearch
      attr_accessor :population
      
      def initialize(initial_population_size, generations, vector_size)
        @population_size = initial_population_size
        @max_generation = generations
        @vector_size = vector_size
        @generation = 0
      end

      def run
        generate_initial_population                    #Generate initial population 
        @max_generation.times do
          selected_to_breed = selection                #Evaluates current population 
          offsprings = reproduction selected_to_breed  #Generate the population for this new generation
          replace_worst_ranked offsprings
        end
        return best_chromosome
      end
    
      def generate_initial_population
        @population = []
        @population_size.times do
          population << Chromosome.seed(@vector_size)
        end
      end
    
      def selection


        
        return Chromosome.new(data_spawn)
      end
      
      def self.seed(size)
        data_size = size
        seed = [] 
        data_size.times do 
          seed << rand(2)
        end
        return Chromosome.new(seed)
      end
    
    end
  
  end
end

puts "Beginning genetic search, please wait... "
search = FIDIUS::GeneticAlgorithm::GeneticSearch.new(800, 100, 10)
result = search.run
puts "Result cost: #{result.fitness}"
puts "Reslt tour: #{result.data}"
