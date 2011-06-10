module FIDIUS
  module Action
    module Scan
      class PortScan < NmapScan

        class AuxiliaryReportListener
          include DRbUndumped

          def initialize(interface)
            @interface = interface
          end

          def report_service(calledClass, opts)
            return unless "auxiliary/scanner/portscan/tcp" == calledClass.fullname
            service = FIDIUS::Service.find_or_create_by_port_and_proto_and_interface_id(opts[:port], "tcp", @interface.id)
            service.state = opts[:state]
            @interface.services << service
            service.save
          end

        end # class AuxiliaryReportListener

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
              service.state = p["state"] if p["state"]
              @interface.services << service
              service.save
            end
            @interface.host.os_name = p["ostype"] if p["ostype"]
            @interface.host.save
          end
        end

        def execute_msf session
          @ports_config ||= YAML.load_file File.expand_path("../../../../../config/services.yml", __FILE__)
          ports = []
          @ports_config.each do |port|
            ports << port["port"] if port["proto"] == "tcp"
          end

          listener = AuxiliaryReportListener.new @interface
          FIDIUS::Action::Msf.instance.add_auxiliary_report_listener listener
          options = {'RHOSTS' => @target, 'PORTS' => ports }
          FIDIUS::Action::Msf.instance.run_auxiliary("auxiliary/scanner/portscan/tcp", options, false)
          FIDIUS::Action::Msf.instance.remove_auxiliary_report_listener listener
          result
        end

      end # class PortScan
    end # module Scan
  end # module Action
end # module FIDIUS

