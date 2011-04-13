require 'drb'

module FIDIUS
  module Server
    class MsfDRb

      attr_reader :uri
      attr_reader :framework

      def initialize
        @framework = Msf::Simple::Framework.create
        @plugin_basepath = File.expand_path('../../../../lib/msf_plugins/', __FILE__)
        @modules = {}
      end

      class << self
        def start_service(config)
          puts "[*] Starting service."
          Signal.trap("INT") do
            puts "[*] Stopping service."
            DRb.thread.kill
          end        
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
          @framework.plugins.load name, opts
          @loaded << name
        end
      end
      
      def unload_plugin(name)
        if @loaded.include? name
          @framework.plugins.unload name
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

      def debug
        p @framework
        p @framework.sessions
      end

    private
      def method_missing(method, *args, &block)
        @framework.send(method, *args, &block)
      end

    end # class MsfDRbD
  end # module Server
end # module FIDIUS
