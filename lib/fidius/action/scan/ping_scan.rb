module FIDIUS
  module Action
    module Scan
      class PingScan < NmapScan

        # returns an array of hosts (which are up) in a given subnet
        def initialize subnet
          raise ArgumentError, "target not set" unless subnet
          @subnet = subnet
          @hosts = []
        end

        def result
          @hosts
        end

        def extract h
          if h["status"] == "up"
            #puts h["addrs"]["ipv4"]
            @hosts << h["addrs"]["ipv4"]
          end
        end

        def create_arg tmpfile
          args = ["-sP", @subnet]
          args.push('-oX', tmpfile)
        end

      end # class PingScan
    end # module Scan
  end # module Action
end # module FIDIUS

