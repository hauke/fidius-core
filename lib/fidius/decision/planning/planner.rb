module FIDIUS

  class Planner
    require 'fidius/decision/planning/cfflib/pddl_prob'
    require 'fidius/decision/planning/cfflib/planparser'
    require 'fidius/decision/planning/cfflib/action_model'
    
    @@DOMAIN = "fidius"
    @@CUR_DOMAIN = "lib/fidius/decision/planning/domain.pddl"
    @@CUR_PROB = "fidius_prob.pddl"
    @@CUR_PLAN = "fidius.plan"

    attr_accessor :hosts

    def initialize
      @nets = {}
      @hosts = []
      @action_model = nil
    end
   
    def plan(services, initial_host, target_host) # returns action model
      create_problem(services, initial_host, target_host)
      # Uncomment when cff is installed
      # create_plan()
      # parse_plan()
    end

    private

    def id_for_net net
      if @nets.has_key?(net)
        return @nets[net]
      end
      @nets[net] = @nets.length + 1
      return @nets[net]
    end

    def neighbours host
      subnet = host.subnet
      subnet.get_hosts
    end

    def create_plan
      proc = IO.popen("cff -o #{@@CUR_DOMAIN} -f #{@@CUR_PROB} > #{@@CUR_PLAN}", "r+")
      proc.close         
    end
    
    # services we want to exploit
    def create_problem(services, initial_host, target_host)
      problem = PlanningProblem.new("fidius", @@DOMAIN)
      
      # add services 
      services.each do |s|
        problem.add_object(s.name, "service")
      end
      
      # add hosts
      @hosts.each do |host|
        problem.add_object("host#{host.id}", "computer")
        #problem.add_object(host.id, "computer")
        host.subnets.each do |sub| 
          p = Predicate.new("host_subnet")
          p.add_object("host#{host.id}")
          p.add_object("net#{id_for_net(sub.ip_range)}")
          problem.add_object("net#{id_for_net(sub.ip_range)}", "net")
          problem.add_predicate(p)
        end

        # host' s possible services
        unknown = Unknown.new
        services.each do |s|
          service = Predicate.new("service_running")
          service.add_object("host#{host.id}")
          service.add_object(s.name)
          unknown.add_unkown(service)
          unknown.add_oneof(service)
        end
        problem.add_predicate(unknown)

        # neighbours
        neighbours = host.neighbours?
        neighbours.each do |neighbour|
          visible = Predicate.new("host_visible")
          visible.add_object("host#{host.id}")
          visible.add_object("host#{neighbour.id}")
          problem.add_object("host#{neighbour.id}", "computer")
          problem.add_predicate(visible)
        end
      end
      
      # starting at initial_host
      p = Predicate.new("on_host")
      p.add_object("host#{initial_host.id}") 
      problem.add_predicate(p)

      # goal is to exploit target
      goal_p = Predicate.new("on_host")
      goal_p.add_object("host#{target_host.id}") 
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
