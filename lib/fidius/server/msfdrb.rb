require 'drb'
require 'singleton'

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

module Msf
  module Auxiliary::Report

    alias_method :orig_report_service, :report_service
    def report_service(opts)
      FIDIUS::Server::ReportDispatcher.instance.report_service(self, opts)
      orig_report_service(opts)
    end

    alias_method :orig_report_host, :report_host
    def report_host(opts)
      FIDIUS::Server::ReportDispatcher.instance.report_host(self, opts)
      orig_report_host(opts)
    end
  end
end

module FIDIUS
  module Server

    class SessionDispatcher
 
      def initialize
        @session_listener = []
      end
   
      def register_session_handler listener
        cleanup
        @session_listener << listener
      end

      def unregister_session_handler listener
        @session_listener.delete listener
      end

      def on_session_open(session)
        cleanup
        @session_listener.each do |sub|
          sub.on_session_open(session)
        end
      end

      def on_session_close(session, reason='')
        cleanup
        @session_listener.each do |sub|
          sub.on_session_close(session, reason)
        end
      end

      def cleanup
        puts "cleanup"
        @session_listener.delete_if do |sub|
          begin
            "ok" != sub.status
          rescue
            puts "can not send message to drb client and remove it"
            true
          end
        end
      end

    end # class SessionListener

    class ReportDispatcher
      include Singleton

      def initialize
        @report_listener = []
      end

      def add_report_listener listener
        @report_listener << listener
      end

      def remove_report_listener listener
        @report_listener.delete listener
      end

      def report_host(calledClass, opts)
        @report_listener.each do |listener|
          next unless listener.respond_to?("report_host")
          listener.report_host(calledClass, opts)
        end
      end
   
      def report_service(calledClass, opts)
        @report_listener.each do |listener|
          next unless listener.respond_to?("report_service")
          listener.report_service(calledClass, opts)
        end
      end

    end # class ReportDispatcher

    class MsfDRb

      attr_reader :uri
      attr_reader :framework

      def initialize
        @framework = create_framework
        @plugin_basepath = File.expand_path('../../../../lib/msf_plugins/', __FILE__)
        @modules = {}
        @sessionDispatcher = SessionDispatcher.new
        @framework.events.add_session_subscriber @sessionDispatcher
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

      def add_session_listener listener
        @sessionDispatcher.register_session_handler listener
      end

      def remove_session_listener listener
        @sessionDispatcher.unregister_session_handler listener
      end

      def add_auxiliary_report_listener listener
        FIDIUS::Server::ReportDispatcher.instance.add_report_listener listener
      end

      def remove_auxiliary_report_listener listener
        FIDIUS::Server::ReportDispatcher.instance.remove_report_listener listener
      end

      def debug
        p @framework
        p @framework.sessions
      end

      def status
        "running"
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
