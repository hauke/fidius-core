require 'drb'
require 'drb/acl'

class DRb::DRbMessage
  def dump(obj, error=false)  # :nodoc:
    if obj.class.to_s.include? "Msf::" or obj.class.to_s.include? "::Metasploit3" or obj.class.to_s.include? "Rex::" or obj.kind_of? DRbUndumped
      obj = make_proxy(obj, error)
    end
    begin
      str = Marshal::dump(obj)
    rescue
      str = Marshal::dump(make_proxy(obj, error))
    end
    [str.size].pack('N') + str
  end
end

module FIDIUS
  module Server
    class MsfDRb

      attr_reader :uri
      attr_reader :framework

      def initialize
        @framework = create_framework
        @plugin_basepath = File.expand_path('../../../../lib/msf_plugins/', __FILE__)
        @modules = {}
        @rangewalker = []
      end

      class << self
        def start_service(config)
          puts "[*] Starting service."
          Signal.trap("INT") do
            puts "[*] Stopping service."
            DRb.thread.kill
          end


          # FIXME: DRb.install_acl ACL.new(%w[deny all allow #{config['host']}])
          uri = "druby://#{config['host']}:#{config['port']}"
          puts "[*] Loading Metasploit framework."
          obj = self.new
          DRb.start_service uri, obj
          puts "[*] Loaded. Listening on `#{uri}'"
          DRb.thread.join
          puts "[*] Quit."
        end
      end

      def load_plugin(name, opts={})
        @loaded ||= []
        unless @loaded.include? name
          puts "loading ... #{name}"
          path = File.join(@plugin_basepath, name) unless name =~ /^\//
          path ||= name 
          @framework.plugins.load path, opts
          @loaded << name
        end
      end

      def unload_plugin(name)
        if @loaded.include? name
          path = File.join(@plugin_basepath, name) unless name =~ /^\//
          path ||= name
          @framework.plugins.unload path
          @loaded.delete name
        end
      end

      def list_plugins
        Dir.glob(File.join @plugin_basepath, "**/*.rb").map {|f|
          f.gsub(@plugin_basepath, '').gsub(/\.rb$/, '')
        }
      end

      def run_exploit(exploit, opts)
        mod = @framework.modules.create(exploit)
        Msf::Simple::Exploit.exploit_simple(mod, opts)
      end

      def run_auxiliary(auxiliary, opts)
        mod = @framework.modules.create(auxiliary)
        Msf::Simple::Auxiliary.run_simple(mod, opts)
      end

      # Creates a new module or returns an older module for the given name.
      # This method holds a reference to the module so the GC does not clean
      # the module up while it is still in use by some drb client.
      #
      # @param [String]  module_name Name of the module
      # @return [Metasploit3] The module
      def module_create(module_name)
        @modules[module_name] ||= @framework.modules.create(module_name)
      end

      def modules_clear
        @modules[module_name] = {}
      end

      # Returns the switchbard instance. This is needed to forward traffic
      # through a meterpreter session.
      def get_switch_board
        Rex::Socket::SwitchBoard.instance
      end

      # Returns a object which iterates over the ips in an ip range.
      def create_range_walker cidr
        walker = Rex::Socket::RangeWalker.new(cidr)
        @rangewalker << walker
        walker
      end

      def destroy_range_walker walker
        @rangewalker.delete walker
      end

      def debug
        p @framework
        p @framework.sessions
      end

    private
      def method_missing(method, *args, &block)
        @framework.send(method, *args, &block)
      end

      def create_framework
        Msf::Simple::Framework.create
      end

    end # class MsfDRbD
  end # module Server
end # module FIDIUS

