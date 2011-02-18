
# TODO make this saveable to database
module FIDIUS
  module Asset
    class Host < ActiveRecord::Base

      #attr_accessor :services, :name, :ip

      #def initialize name, ip
        # should be nil if services unknown, an empty array 
        # if host has no services and a list of Service instances if
        # any services has been discovered yet
      #  @services = nil
      #  @name = name
      #  @ip = ip
      #end

      def exploited?
        raise NotImplementedError, "not implemented yet"
      end

      def reachable?
        raise NotImplementedError, "not implemented yet"
      end

      def get_services_as_bit_vector
        return [] unless @services

        bit_vector = []
        
        known = FIDIUS::MachineLearning::known_services

        known.each do |service|
          bit_vector << (@services.include?(service) ? 1 : 0)
        end
        bit_vector
      end
      
      def get_subnets
        raise NotImplementedError, "not implemented yet"
      end
      
      def add_subnet
        raise NotImplementedError, "not implemented yet"
      end

      def reachable_trough
        # should return gateway host through which one 
        raise NotImplementedError, "not implemented yet"
      end

      def get_session
        raise NotImplementedError, "not implemented yet"
      end

      def ports_scanned?
        raise NotImplementedError, "not implemented yet"
      end

      def hostname
        raise NotImplementedError, "not implemented yet"
      end

      def mac_addr
        raise NotImplementedError, "not implemented yet"
      end

      def ==
          raise NotImplementedError, "not implemented yet"
      end

    end # class Host
  end # module Asset
end # module FIDIUS

