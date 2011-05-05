PROBLEM = "problem"
DOMAIN = ":domain"
OBJECTS = ":objects"
GOAL = ":goal"

class Goal

  def initialize(predicate)
    @predicate = predicate
  end

  def to_s
    goal = "(#{GOAL} #{@predicate.to_s})\n"
  end

end

class Predicate
  
  def initialize(name) 
    @name = name
    @objects = []
  end

  def add_object(object)
    @objects << object
  end

  def to_s
    pred_str = " (#{@name} "
    @objects.each do |o|
      pred_str << "#{o} "
    end
    pred_str << " )"
  end

end

class Unknown
  
  def initialize
    @predicates = []
    @oneof = []
  end

  def add_unkown(unkown)
    @predicates << unkown
  end

  def add_oneof(oneof)
    @oneof << oneof
  end

  def to_s
    str = String.new
    @predicates.each do |pred|
      str << " (unknown " <<  pred.to_s << ")\n"
    end
    str << " (oneof "
    @oneof.each do |oneof|
      str << "  " << oneof.to_s << "\n"
    end
    str << " )\n"
  end

end

class PlanningProblem

  def initialize(name, domain_name)
    @name = name
    @domain_name = domain_name
    @objects = []
    @predicates = []
  end

  def set_goal(goal)
    @goal = goal
  end

  def add_object(object, type)
    @objects << object << " - " << type if !@objects.include?(object)
  end

  def add_predicate(predicate)
    @predicates << predicate
  end

  def to_s
    problem =  "(define "
    problem << " (#{PROBLEM} #{@name}) \n"
    problem << " (#{DOMAIN} #{@domain_name}) \n"
    problem << " (#{OBJECTS} "
    @objects.each do |o|
      problem << "#{o} "
    end
    problem << ") \n"
    problem << " (:init \n "
    @predicates.each do |p|
      problem << p.to_s << " \n"
    end
    problem << " ) \n"
    problem << " " << @goal.to_s()
    problem << ") \n"
  end

  def write(file_name)
    File.open(file_name, 'w') do |file|
      file.puts to_s
    end
  end
  
end
