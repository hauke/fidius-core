require 'cfflib/pddl_prob'
require 'cfflib/planparser'
require 'cfflib/action_model'

module FIDIUS
  # include MachineLearning # known services

  class Planner
    
    @@DOMAIN = "domain.pddl"
    @@CUR_PROB = "fidius_prob.pddl"
    @@CUR_PLAN = "fidius.plan"

    attr_accessor :hosts, :subnets

    def initialize
      @hosts = []
      @subnets = []
      @action_model = nil
    end
   
    def plan
#      create_problem()
#      create_plan()
      parse_plan()
    end

    private
    def create_plan
      proc = IO.popen("cff -o #{@@DOMAIN} -f #{@@CUR_PROB} > #{@@CUR_PLAN}", "r+")
      proc.close         
    end
    
    def create_problem(services, initial_host)
      problem = PlanningProblem.new(@@CUR_PROB, @@DOMAIN)
      
      # add services 
      services.each do |s|
        problem.add_object(s.name, "service")
      end
      
      # add hosts
      hosts.each do |host|
        problem.add_object(host.id, "computer")
        host.get_subnets do |sub|
          p = Predicate.new("host_subnet")
          p.add_object(host.host_name)
          p.add_object(sub)
          problem.add_predicate(p)
        end
      end

      # host' s possible services
      unknown = Unknown.new
      services.each do |s|
        service = Predicate.new("service_running")
        service.add_object(host.host_name)
        service.add_object(s.name)
        unknown.add_unkown(service)
        unknown.add_oneof(service)
      end
      problem.add_predicate(unknown)
    end

    def parse_plan
      parser = CffParser.new(@@CUR_PLAN)
      @action_model = ActionModel.new(parser.tree)
    end

  end  # Planner
end # FIDIUS
