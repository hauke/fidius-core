module FIDIUS

class Service

  attr_accessor :port, :name, :proto

  def initialize(name, port, proto)
    @name = name
    @port = port
    @proto = proto # tcp or udp
  end

  def get_exploits
    raise NotImplementedError, "not implemented yet"
  end

  def to_s
    raise NotImplementedError, "not implemented yet"
  end

  def == x
    @name.eql? x.name and @port == x.port and @proto == x.proto      
  end

end # class Service
end # module FIDIUS
