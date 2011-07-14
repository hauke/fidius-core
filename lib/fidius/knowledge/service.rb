module FIDIUS
  class Service < ActiveRecord::Base
    belongs_to :interface, :class_name => "FIDIUS::Asset::Interface"

    def get_exploits
      raise NotImplementedError, "not implemented yet"
    end

    def to_s
      raise NotImplementedError, "not implemented yet"
    end

    def name_or_ip
      return interface.host.name if interface.host.name
      return interface.ip
    end

    def == other
      return false unless other
      return false if other.port != port
      return false if other.proto != proto
      return true
    end
  
  end # class Service
end # module FIDIUS
