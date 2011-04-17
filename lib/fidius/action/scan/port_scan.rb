module FIDIUS
  module Action
    module Scan
      class PortScan < NmapScan

        def initialize target, port_range = nil
          raise ArgumentError, "target not set" unless target
          raise ArgumentError, "target isnt a target-Object" unless target.ip
          @target = target
          @target.services = []
          @port_range = port_range
        end

        def result
          @target
        end

        def create_arg tmpfile
          if @port_range
            args = ["-sV -p #{@port_range}", @target.ip]
          else
            args = ["-sV", @target.ip]
          end
          args.push('-oX', tmpfile)
        end

        def extract h
          h["ports"].each do |p|
            #puts "Port found: #{p}"
            if p["state"] == "open"
              service = FIDIUS::Service.find_or_create_by_port_and_proto_and_interface_id(p["portid"], p["protocol"], @target.id)
              service.info = p["product"] if p["product"]
              service.name = p["name"] if p["name"]
              @target.services << service
              service.save
            end
            @target.host.os_name = p["ostype"] if p["ostype"]
            @target.host.save
          end
        end

      end # class PortScan
    end # module Scan
  end # module Action
end # module FIDIUS

