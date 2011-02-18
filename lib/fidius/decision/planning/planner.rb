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
    
    def create_problem
      raise "not implemented error"
    end

    def parse_plan
      parser = CffParser.new(@@CUR_PLAN)
      @action_model = ActionModel.new(parser.tree)
    end

  end  # Planner
end # FIDIUS
