# cff output format constants
SKIP = "-------------------------------------------------" 
NODE_INDEX_DELIM = "||"
ELEM_DELIM  = "---"
TRUE_PATH = "TRUESON:"
PATH = "SON:"
FALSE_PATH = "FALSESON:"

ACTION_POS = 1
NODE_OFFSET = 2

BEGIN_PLAN = "ff: found plan as follows"

# An action node for "Attack trees" 
class Node
  
  attr_accessor :action, :true_succ, :false_succ

  def initialize(action)
    @action = action
    @true_succ = nil
    @false_succ = nil
  end

end
  
# Parser for ContingentFF output plans
class CffParser

  attr_reader :tree

  def initialize(file)
    process(file)
  end

  def search()
    depth_first(@tree)
  end

  private

  def build_node(index_map, str)
    components = str.strip.split(ELEM_DELIM)
    node = Node.new(components[1])
    if components.size - NODE_OFFSET == 0
      return node
    end
    for i in (NODE_OFFSET ... components.size)
      node_type = components[i].strip.split(" ")
      node_line = index_map[node_type[1]]
      if node_line != nil
        if node_type[0] == TRUE_PATH || node_type[0] == PATH 
          node.true_succ = build_node(index_map, node_line)
        else
          node.false_succ = build_node(index_map, node_line)
        end
      else
        return node
      end
    end
    return node
  end  

  def depth_first(tree)
    # pre order 
    if tree != nil
      puts tree.action 
      depth_first(tree.true_succ)
      depth_first(tree.false_succ)
    end
  end

  # Parse the file to {node_index => node_string}
  def process(file)
    node_index = ""
    nodes = {}
    started = false
    in_fp = File.new(file,"r")
    in_fp.each_line do |line| 
      if line.strip != SKIP && started
        if line.strip == ""
          started = false
          break;
        end
        components = line.split(ELEM_DELIM)
        if components[0][NODE_INDEX_DELIM]
          node_index = components[0].strip
          nodes[node_index] = line.strip
        else
          nodes[node_index] << line.strip
        end
      end
      started = true if line.strip == BEGIN_PLAN
    end
    root = nodes.keys.sort[0]
    @tree = build_node(nodes, nodes[root])
  end
end  
