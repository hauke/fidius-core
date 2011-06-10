module FIDIUS
  module Action
    module Scan
      class ArpScan < NmapScan

        class AuxiliaryReportListener
          include DRbUndumped

          def initialize(result)
            @result = result
          end

          def report_host(calledClass, opts)
            return unless "post/windows/gather/arp_scanner" == calledClass.fullname
            puts "found host #{opts}"
            @result << opts[:host]
          end

        end # class AuxiliaryReportListener

        # returns an array of hosts (which are up) in a given subnet
        def initialize target
          raise ArgumentError, "target not set" unless target
          @target = target
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
          args = ["-PR", @target]
          args.push('-oX', tmpfile)
        end

        def execute_msf session
          result = []
          listener = AuxiliaryReportListener.new result
          FIDIUS::Action::Msf.instance.add_auxiliary_report_listener listener
          options = {'RHOSTS' => @target, 'SESSION' => session.name, 'THREADS' => 10}
          FIDIUS::Action::Msf.instance.run_auxiliary("windows/gather/arp_scanner", options, false)
          FIDIUS::Action::Msf.instance.remove_auxiliary_report_listener listener
          return result
        end

      end # class ArpScan
    end # module Scan
  end # module Action
end # module FIDIUS

