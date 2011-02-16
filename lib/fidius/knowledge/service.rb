class FIDIUS::Service < Struct.new(:name, :port, :proto)

  def get_exploits
    raise NotImplementedError, "not implemented yet"
  end

  def to_s
    raise NotImplementedError, "not implemented yet"
  end
  
end # class FIDIUS::Service
