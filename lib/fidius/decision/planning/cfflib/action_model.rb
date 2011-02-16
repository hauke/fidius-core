class ActionModel
  
  def initialize tree
    @tree = tree
  end

  def get_next_action
    return @tree
  end

  def success
    @tree = @tree.true_succ
  end
  
  def fail
    @tree = @tree.false_succ
  end

end
