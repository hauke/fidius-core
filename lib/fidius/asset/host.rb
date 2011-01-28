
module FIDIUS

module Asset


# TODO make this saveable to database
class Host # < ActiveRecord
  
  def initialize 
    raise NotImplementedError, "not implemented yet"
  end

  def scan type, port_range = nil
    raise NotImplementedError, "not implemented yet"
  end

  def scanned?
    raise NotImplementedError, "not implemented yet"
  end

  def hostname
    raise NotImplementedError, "not implemented yet"
  end

  def ip
    raise NotImplementedError, "not implemented yet"
  end

  def mac_addr
    raise NotImplementedError, "not implemented yet"
  end

  

end

end # module Asset
end # module FIDIUS
