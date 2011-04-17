module FIDIUS
  module Action
    module Scan
      
      autoload :ArpScan,  'fidius/action/scan/arp_scan'
      autoload :PingScan, 'fidius/action/scan/ping_scan'
      autoload :PortScan, 'fidius/action/scan/port_scan'
      autoload :NmapScan, 'fidius/action/scan/nmap_scan'
      
      #
      # initilizing the scan
      #
      def init_scan
        # should save the current state of msf host list
        raise NotImplementedError, "method must be implemented by subclass"
      end

      def check_param host
        return true if host.is_a FIDIUS::Asset::Host
        nil
      end

      # 
      def get_success
        # should return a list of hosts which are new after scan
        raise NotImplementedError, "method must be implemented by subclass"
      end

      def initialize target
        @target = target
      end

      def loudness
        raise NotImplementedError, "method must be implemented by subclass"
      end
      
    end # module Scan
  end # module Action
end # module FIDIUS

