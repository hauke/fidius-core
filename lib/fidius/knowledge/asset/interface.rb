module FIDIUS
  module Asset
    class Interface < ActiveRecord::Base
      has_many :services, :class_name => "FIDIUS::Service"
      belongs_to :host

      #attr_accessor :services, :name, :ip

      after_create do
        agent = FIDIUS::MachineLearning::agent
        agent.add(self)
      end

      def reachable?
        raise NotImplementedError, "not implemented yet"
      end

      def get_services_as_bit_vector
        @services = [] unless @services
        bit_vector = []
        known = FIDIUS::MachineLearning::known_services
        known.each do |service|
          bit_vector << (@services.include?(service) ? 1 : 0)
        end
        bit_vector
      end

      def reachable_trough
        # should return gateway host through which one 
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

    end # class Host
  end # module Asset
end # module FIDIUS

