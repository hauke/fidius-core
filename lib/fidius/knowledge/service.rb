module FIDIUS
  class Service < ActiveRecord::Base

    def get_exploits
      raise NotImplementedError, "not implemented yet"
    end

    def to_s
      raise NotImplementedError, "not implemented yet"
    end
  
  end # class Service
end # module FIDIUS
