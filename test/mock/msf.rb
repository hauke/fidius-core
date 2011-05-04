module FIDIUS
  module MsfMock
    class Framework

      def initialize
        @modules = ModuleSetMock.new
        @sessions = {}
        @events = EventDispatcherMock.new

        @modules["exploit/http"] = ExploitMock.new "exploit/http", 80
        @modules["exploit/smb"] = ExploitMock.new "exploit/smb", 445
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

    class ExploitMock

      def initialize fullname, port
        @fullname = fullname
        @datastore = {}
        @datastore["RPORT"] = port
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

    end #class ModuleSetMock

    class SessionMock

      def initialize name, exploit_name
        @exploit_name = exploit_name
        @name = name
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

    end #class ModuleSetMock
  end # module MsfMock
end # module FIDIUS
