module FIDIUS

class Service < Struct.new(:port, :name, :proto)

  def get_exploits
    raise NotImplementedError, "not implemented yet"
  end

  def to_s
    raise NotImplementedError, "not implemented yet"
  end

end # class Service
end # module FIDIUS
