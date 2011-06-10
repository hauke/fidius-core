require "ipaddr"

module FIDIUS
  class Subnet
  
    attr_accessor :ip_range

    def initialize ip_range
      if ip_range.is_a? String
        @ip_range = IPAddr.new ip_range
      elsif ip_range.is_a? IPAddr
        @ip_range = ip_range
      else
        raise ArgumentError.new "arguemtn is neither an string nor an ip address object"
      end
    end

    def ==(subnet)
      self.ip_range.to_s == subnet.ip_range.to_s
    end

    def get_hosts
      raise NotImplementedError, "not implemented yet"      
    end

    def get_asset
      raise NotImplementedError, "not implemented yet"
    end

    def add_asset
      raise NotImplementedError, "not implemented yet"
    end
    
  end # class Subnet
end # module FIDIUS

if __FILE__ == $0
  FIDIUS::Subnet.new "192.168.56.0/4"
end
