module FIDIUS
  class Service < ActiveRecord::Base
    belongs_to :interface, :class_name => "FIDIUS::Asset::Interface"

    def get_exploits
      raise NotImplementedError, "not implemented yet"
    end

    def to_s
      raise NotImplementedError, "not implemented yet"
    end
  
  end # class Service
end # module FIDIUS
