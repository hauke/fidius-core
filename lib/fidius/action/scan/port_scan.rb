module FIDIUS
  module Action
    module Scan
      class PortScan < NmapScan

        def initialize target, port_range = nil
          raise ArgumentError, "target not set" unless target
          raise ArgumentError, "target isnt a target-Object" unless target.ip
          @interface = target
          @interface.services = []
          @target = target.ip
          @port_range = port_range
        end

        def result
          @interface
        end

        def create_arg tmpfile
          if @port_range
            args = ["-sV -p #{@port_range}", @target]
          else
            args = ["-sV", @target]
          end
          args.push('-oX', tmpfile)
        end

        def extract h
          h["ports"].each do |p|
            #puts "Port found: #{p}"
            if p["state"] == "open"
              service = FIDIUS::Service.find_or_create_by_port_and_proto_and_interface_id(p["portid"], p["protocol"], @interface.id)
              service.info = p["product"] if p["product"]
              service.name = p["name"] if p["name"]
              @interface.services << service
              service.save
            end
            @interface.host.os_name = p["ostype"] if p["ostype"]
            @interface.host.save
          end
        end

      end # class PortScan
    end # module Scan
  end # module Action
end # module FIDIUS

