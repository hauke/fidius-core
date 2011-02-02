module FIDIUS

module Asset

# TODO make this saveable to database
class Host # < ActiveRecord
  
  def initialize 
    raise NotImplementedError, "not implemented yet"
  end

  def exploited?
    raise NotImplementedError, "not implemented yet"
  end

  def reachable?
    raise NotImplementedError, "not implemented yet"
  end

  def get_services
    # should return nil of services unknown, an empty array 
    # if host has no services and a list of Service instances if
    # any services has been discovered yet
    raise NotImplementedError, "not implemented yet"
  end

  def get_services_as_bit_vector
    services = get_services
    return [] unless services
    services.each do |service|
    end
  end
  
  def get_subnets
    raise NotImplementedError, "not implemented yet"
  end
  
  def add_subnet
    raise NotImplementedError, "not implemented yet"
  end

  def reachable_trough
    # should return gateway host through which one 
    raise NotImplementedError, "not implemented yet"
  end

  def get_session
    raise NotImplementedError, "not implemented yet"
  end

  def ports_scanned?
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

  def self.==
      raise NotImplementedError, "not implemented yet"
  end

end

end # module Asset
end # module FIDIUS


