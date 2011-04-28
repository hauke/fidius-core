require 'pddl_prob'

# Call Contigent FF planner
def plan(domain, problem, out)
  proc = IO.popen("cff -o #{domain} -f #{problem} > #{out}", "r+")
  proc.close         
end

def eval_performance(num_nodes, branching_fac, num_services)
  problem = PlanningProblem.new('fidius_net', 'fidius')

  # starting in subnet 1
  problem.add_object("net1", "net")
  p_0 = Predicate.new("in_subnet")
  p_0.add_object("net1")

  # starting on host0
  p_1 = Predicate.new("on_host")
  p_1.add_object("host0")
  problem.add_predicate(p_1)

  num_services.times do |i|
    problem.add_object("service#{i}", "service")   
  end

  num_nodes.times do |i|
    problem.add_object("host#{i}", "computer")
    
    # host in subnet ? 
    sub = Predicate.new("host_subnet")
    sub.add_object("host#{i}")
    sub.add_object("net1")
    problem.add_predicate(sub)
    
    # host' s neighbours
    branching_fac.times do
      num_neighbour = rand(num_nodes)
      if num_neighbour != i
        neighbour = Predicate.new("host_visible")
        neighbour.add_object("host#{i}")
        neighbour.add_object("host#{num_neighbour}")
        problem.add_predicate(neighbour)
      end
    end

    # host' s possible services
    unknown = Unknown.new
    num_services.times do |j|
      service = Predicate.new("service_running")
      service.add_object("host#{i}")
      service.add_object("service#{j}")
      unknown.add_unkown(service)
      unknown.add_oneof(service)
    end
    problem.add_predicate(unknown)
  end
  return problem
end

# Experiment
node_stepwidth = 4
branch_fac_stepwidth = 2
service_stepwidth = 2

times_needed = []
iterations = 1

iterations.times do |i|
  start = Time.now
  nodes = (i + 1) * node_stepwidth
  branching_fac = (i + 1) * branch_fac_stepwidth
  service = (i + 1) * service_stepwidth 

  problem = eval_performance(nodes , branching_fac, service)
  goal = Predicate.new("on_host")
  goal.add_object("host#{nodes  - 1}")
  problem.set_goal(Goal.new(goal))
  problem.write("#{i}.pddl")
  plan("../domain.pddl", "#{i}.pddl", "#{i}.out")  

  puts "----------------------------------"
  puts "\#nodes: #{nodes}"
  puts "brachning factor: #{branching_fac}"
  puts "\#services: #{service}"
  puts "time:#{Time.now - start} [s]"
  puts "----------------------------------"
end  
