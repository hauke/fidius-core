module FIDIUS
  class Service < ActiveRecord::Base
    belongs_to :host, :class_name => "FIDIUS::Asset::Host"

    def get_exploits
      raise NotImplementedError, "not implemented yet"
    end

    def to_s
      raise NotImplementedError, "not implemented yet"
    end
  
  end # class Service
end # module FIDIUS
