# Tool will optimize a snort rule set 
#
# Customized from ai4r
module GeneticAlgorithm
  class GeneticSearch
    attr_accessor :population
    
    def initialize(initial_population_size, generations)
      @population_size = initial_population_size
      @max_generation = generations
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
        population << Chromosome.seed
      end
    end
    
    def selection
      @population.sort! { |a, b| b.fitness <=> a.fitness}
      best_fitness = @population[0].fitness
      worst_fitness = @population.last.fitness
      acum_fitness = 0
      if best_fitness-worst_fitness > 0
        @population.each do |chromosome| 
          chromosome.normalized_fitness = (chromosome.fitness - worst_fitness)/(best_fitness-worst_fitness)
          acum_fitness += chromosome.normalized_fitness
        end
      else
        @population.each { |chromosome| chromosome.normalized_fitness = 1}  
      end
      selected_to_breed = []
      ((2*@population_size)/3).times do 
        selected_to_breed << select_random_individual(acum_fitness)
      end
      selected_to_breed
    end
    
    def reproduction(selected_to_breed)
      offsprings = []
      0.upto(selected_to_breed.length/2-1) do |i|
        offsprings << Chromosome.reproduce(selected_to_breed[2*i], selected_to_breed[2*i+1])
      end
      @population.each do |individual|
        Chromosome.mutate(individual)
      end
      return offsprings
    end
    
    # Replace worst ranked part of population with offspring
    def replace_worst_ranked(offsprings)
      size = offsprings.length
      @population = @population [0..((-1*size)-1)] + offsprings
    end
    
    # Select the best chromosome in the population
    def best_chromosome
      the_best = @population[0]
      @population.each do |chromosome|
        the_best = chromosome if chromosome.fitness > the_best.fitness
      end
      return the_best
    end
    
    private 
    def select_random_individual(acum_fitness)
      select_random_target = acum_fitness * rand
      local_acum = 0
      @population.each do |chromosome|
        local_acum += chromosome.normalized_fitness
        return chromosome if local_acum >= select_random_target
      end
    end
    
  end
  
  class Chromosome

    attr_accessor :data # Bit Vector
    attr_accessor :normalized_fitness
    
    def initialize(data)
      @data = data 
    end
    
    def fitness
      return @fitness if @fitness
      # TODO Implement Fidius Evasion DB test
      # fitness = num_exploit_events / num_false_positives
      # max(fitness)
      @fitness = 0 
      @data.each do |x|
        @fitness = @fitness + x
      end
      return @fitness
    end
    
    def self.mutate(chromosome)
      if chromosome.normalized_fitness && rand < ((1 - chromosome.normalized_fitness) * 0.3)
        data = chromosome.data # get data
        index = rand(data.length-1) # get random index to change
        data[index] = (data[index] == 1) ? 0 : 1
        chromosome.data = data
        @fitness = nil
      end
    end
    
    # single point crossover
    def self.reproduce(a, b)
      data_spawn = []
      data_a = a.data
      data_b = b.data
      split_index = rand(data_a.length - 1) 
      
      data_a.each do |i|
        if i < split_index
          data_spawn << data_a[i]
        else
          data_spawn << data_b[i]
        end
      end
      
      return Chromosome.new(data_spawn)
    end
    
    def self.seed
      data_size = 10 # Num Rules
      seed = [] # get initial bitvector
      data_size.times do 
        seed << rand(2)
      end
      return Chromosome.new(seed)
    end
    
  end
  
end

puts "Beginning genetic search, please wait... "
search = GeneticAlgorithm::GeneticSearch.new(800, 100)
result = search.run
puts "Result cost: #{result.fitness}"
puts "Reslt tour: #{result.data}"
