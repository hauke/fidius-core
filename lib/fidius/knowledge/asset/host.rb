module FIDIUS

module Asset

# TODO make this saveable to database
class Host # < ActiveRecord
  
  attr_accessor :services, :name

  def initialize name
    # should be nil if services unknown, an empty array 
    # if host has no services and a list of Service instances if
    # any services has been discovered yet
    @services = nil
    @name = name
  end

  def exploited?
    raise NotImplementedError, "not implemented yet"
  end

  def reachable?
    raise NotImplementedError, "not implemented yet"
  end

  def get_services_as_bit_vector
    return [] unless @services

    bit_vector = []
    
    known = FIDIUS::MachineLearning::known_services

    known.each do |service|
      if @services.include? service 
        bit_vector << 1
      else
        bit_vector << 0
      end
    end
    bit_vector
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


