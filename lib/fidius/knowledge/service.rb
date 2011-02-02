module FIDIUS

class Service < Struct.new(:name, :port, :proto)

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
