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

  def self.== x
      self.name == x.name && self.port == x.port && self.proto == x.proto      
  end
end # class Service
end # module FIDIUS
