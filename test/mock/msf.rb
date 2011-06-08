module FIDIUS
  module MsfMock
    class Framework

      def initialize
        @modules = ModuleSetMock.new
        @sessions = {}
        @events = EventDispatcherMock.new
        @plugins = PluginsMock.new
        @thread = ThreadMock.new

        @modules["http"] = ExploitMock.new "exploit/http", 80
        @modules["smb"] = ExploitMock.new "exploit/smb", 445
      end

      def exploits
        @modules
      end

      def sessions
        @sessions
      end

      def modules
        @modules
      end

      def events
        @events
      end

      def plugins
        @plugins
      end

      def get_running_multihandler
        [{:lhost =>"127.0.0.1", :payload => "linux/x86/meterpreter/reverse_tcp"}]
      end

      def start_multihandler options
        @thread
      end

      def stop_multihandler jid
        nil
      end

    end # class Framework

    class EventDispatcherMock

      attr_accessor :subscriber
	
      def add_session_subscriber(subscriber)
        @subscriber = subscriber
      end

      def remove_session_subscriber(subscriber)
        @subscriber = nil
      end

    end #class EventDispatcherMock

    class ModuleSetMock < Hash

      def each_module(opts = {}, &block)
        self.each_pair do |name, mod|
          block.call name, mod
        end
      end

      def create module_name
        self[module_name]
      end

    end #class ModuleSetMock

    class PluginsMock

      def load path, opts
        nil
      end

      def unload path
        nil
      end

    end #PluginsMock

    class ThreadMock

      def join
        nil
      end

    end #ThreadMock

    class ExploitMock

      def initialize fullname, port
        @fullname = fullname
        @datastore = {}
        @datastore["RPORT"] = port
      end

      def new
        self
      end

      def fullname
        @fullname
      end

      def disclosure_date
        nil
      end

      def platform_to_s
        nil
      end

      def datastore
        @datastore
      end

      def arch
        "cmd"
      end

      def compatible_payloads
      [["linux/x86/meterpreter/reverse_tcp"]]
      end

    end #class ModuleSetMock

    module Session
      class SessionMock

        def initialize name, exploit_name
          @exploit_name = exploit_name
          @name = name
          @net = NetMock.new
          @sys = SysMock.new
        end

        def name
          @name
        end

        def via_exploit
          @exploit_name
        end

        def via_payload
          "payload/test"
        end

        def load_stdapi
          #Nothing to do
        end

        def load_priv
          #Nothing to do
        end

        def net
          @net
        end

        def sys
          @sys
        end

      end #class ModuleSetMock

      class ConfigMock

        def initialize
          @ipAddresses = [InterfaceMock.new("127.0.0.1"), InterfaceMock.new("192.168.56.100")]
        end

        def each_interface(&block)
          @ipAddresses.each(&block)
        end

        def each_route(&block)

        end

      end # class ConfigMock

      class NetMock

        def initialize
          @config = ConfigMock.new
        end

        def config
          @config
        end

      end # class NetMock

      class InterfaceMock

        def initialize ip
          @ip = ip
        end

        def ip
          @ip
        end

        def netmask
          "255.255.255.0"
        end

        def mac_addr
          "00:11:22:33:44:55"
        end

      end # class InterfaceMock

      class SysMock

        def initialize
          @process = ProcessMock.new
        end

        def process
          @process
        end

      end # class SysMock

      class ProcessMock

        def get_processes
          [{"name" => "explorer.exe"}]
        end

      end # module Session
    end # class ProcessMock

    class SwitchBoard

      def self.best_comm(addr)
        nil
      end
      
      def self.each(&block)
      end

    end # class SwitchBoard
  end # module MsfMock
end # module FIDIUS

module Msf
  module Auxiliary
    module Report

      def report_service(opts)
      end

      def report_host(opts)
      end

    end # module Report
  end # module Auxiliary
end # module Msf
