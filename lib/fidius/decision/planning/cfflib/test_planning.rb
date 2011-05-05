
require 'planparser'
require 'action_model'

# Call Contigent FF planner
def plan(domain, problem, out)
  proc = IO.popen("cff -o #{domain} -f #{problem} > #{out}", "r+")
  proc.close         
end

# Setup test
problem = PlanningProblem.new('fidius_test', 'fidius')

host_1 = "h1"
host_2 = "h2"
host_3 = "h3"

service_1 = "s1"
service_2 = "s2"

net_1 = "net1"

problem.add_object(host_1, "computer")
problem.add_object(host_2, "computer")
problem.add_object(host_3, "computer")
problem.add_object(service_1, "service")
problem.add_object(service_2, "service")
problem.add_object(net_1, "net")

p_1 = Predicate.new("on_host")
p_1.add_object(host_1)

p_2 = Predicate.new("host_subnet")
p_2.add_object(host_1)
p_2.add_object(net_1)

p_3 = Predicate.new("host_subnet")
p_3.add_object(host_2)
p_3.add_object(net_1)

p_4 = Predicate.new("host_subnet")
p_4.add_object(host_3)
p_4.add_object(net_1)

p_5 = Predicate.new("in_subnet")
p_5.add_object(net_1)

p_6 = Predicate.new("host_visible")
p_6.add_object(host_1)
p_6.add_object(host_2)

p_7 = Predicate.new("host_visible")
p_7.add_object(host_2)
p_7.add_object(host_3)

p_8 = Predicate.new("service_running")
p_8.add_object(host_2)
p_8.add_object(service_1)

p_9 = Predicate.new("service_running")
p_9.add_object(host_2)
p_9.add_object(service_2)

p_10 = Predicate.new("service_running")
p_10.add_object(host_3)
p_10.add_object(service_1)

p_11 = Predicate.new("service_running")
p_11.add_object(host_3)
p_11.add_object(service_2)

u_1 = Unknown.new
u_1.add_unkown(p_8)
u_1.add_unkown(p_9)
u_1.add_oneof(p_8)
u_1.add_oneof(p_9)

u_2 = Unknown.new
u_2.add_unkown(p_10)
u_2.add_unkown(p_11)
u_2.add_oneof(p_10)
u_2.add_oneof(p_11)

problem.add_predicate(p_1)
problem.add_predicate(p_2)
problem.add_predicate(p_3)
problem.add_predicate(p_4)
problem.add_predicate(p_5)
problem.add_predicate(p_6)
problem.add_predicate(p_7)
problem.add_predicate(u_1)
problem.add_predicate(u_2)

p_g = Predicate.new("on_host")
p_g.add_object(host_3)
g = Goal.new(p_g)

problem.set_goal(g)

# Generate Plan
problem.write('test.pddl')
plan('../domain.pddl', 'test.pddl', 'test.plan')

# Parse Plan
parser = CffParser.new('test.plan')
parser.search

# Initialize and walk through action model
puts "------ACTION-----"
action_model = ActionModel.new parser.tree
next_action = action_model.get_next_action
while next_action != nil 
  puts next_action.action
  action_model.success
  next_action = action_model.get_next_action
end
