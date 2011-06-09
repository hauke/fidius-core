module FIDIUS

  class Planner
    require 'fidius/decision/planning/cfflib/pddl_prob'
    require 'fidius/decision/planning/cfflib/planparser'
    require 'fidius/decision/planning/cfflib/action_model'
    
    @@DOMAIN = "domain.pddl"
    @@CUR_PROB = "fidius_prob.pddl"
    @@CUR_PLAN = "fidius.plan"

    attr_accessor :hosts

    def initialize
      @hosts = []
      @action_model = nil
    end
   
    def plan(services, initial_host, target_host) # returns action model
      create_problem(services, initial_host, target_host)
      create_plan()
      parse_plan()
    end

    private
    def neighbours host
      subnet = host.subnet
      subnet.get_hosts
    end

    def create_plan
      proc = IO.popen("cff -o #{@@DOMAIN} -f #{@@CUR_PROB} > #{@@CUR_PLAN}", "r+")
      proc.close         
    end
    
    # services we want to exploit
    def create_problem(services, initial_host, target_host)
      problem = PlanningProblem.new("FIDIUS_PROBLEM", @@DOMAIN)
      
      # add services 
      services.each do |s|
        problem.add_object(s.name, "service")
      end
      
      # add hosts
      @hosts.each do |host|
        problem.add_object(host.id, "computer")

        host.subnets.each do |sub| 
          p = Predicate.new("host_subnet")
          p.add_object(host.id)
          p.add_object(sub.ip_range)
          problem.add_predicate(p)
        end

        # host' s possible services
        unknown = Unknown.new
        services.each do |s|
          service = Predicate.new("service_running")
          service.add_object(host.id)
          service.add_object(s.name)
          unknown.add_unkown(service)
          unknown.add_oneof(service)
        end
        problem.add_predicate(unknown)
      end
      
      # starting at initial_host
      p = Predicate.new("on_host")
      p.add_object(initial_host.id)
      problem.add_predicate(p)

      # goal is to exploit target
      goal_p = Predicate.new("on_host")
      goal_p.add_object(target_host.id)
      goal = Goal.new(goal_p)
      problem.set_goal(goal)

      problem.write(@@CUR_PROB)
    end

    def parse_plan
      parser = CffParser.new(@@CUR_PLAN)
      @action_model = ActionModel.new(parser.tree)
    end

  end  # Planner
end # FIDIUS
