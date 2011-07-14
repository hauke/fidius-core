require "xmlrpc/server"

require "fidius-common"
require "fidius-common/json_symbol_addon"
require "fidius/server/data_changed_patch"
require "fidius/misc/asset_initialiser"

require "fidius/server/handlers/handlers"
require "fidius/server/task_manager"

require 'webrick'

module XMLRPC
  class Server
    def serve
      @server.start
    end
  end
end

module FIDIUS
  module Server
    require 'webrick/httputils'
    class PayloadHandler < WEBrick::HTTPServlet::AbstractServlet
      def initialize(server, local_path)
        super(server, local_path)
        @local_path = local_path
      end
      
      def do_GET(request, response)
        status, mime, body = payload_for_request(request)
        response.status = status
        response['Content-Type'] = mime
        response.body = body
      end

      private
      
      def payload_for_request request
        case request.path.split('/').last
        when "linux"
          payload = "YEAH"
          payload = open("#{@local_path}/payloads/test.bin", "r") #send File
        when "windows"
          #payload = open("#{@local_path}/payloads/#{}","rb")
        when "osx"
          #payload = open("#{@local_path}/payloads/#{}","rb")
        end
        return 200, "application/octet-stream", payload if payload
        return 400, "text/plain","You gave me #{request.path} -- I have no idea what to do with that."
      end
    end
    
    class RPC < ::XMLRPC::Server

      def initialize(options={}, *args)
        # TODO: simplify
        options = {
          'max_connections' => 4,
          'stdlog' => $stdout,
          'audit' => true,
          'debug' => true
        }.merge options
        super(
          options['port'],
          options['host'],
          options['max_connections'],
          options['stdlog'],
          options['audit'],
          options['debug'],
          *args
        )
        add_handlers
        set_service_hook do |obj, *args|
          # XXX: here might be a nice entry point to avoid code dublettes
          #      like in line 38/42
          obj.call(*args)
        end
        @server.mount("/payloads",PayloadHandler,"#{Dir.pwd}")
        begin
          FIDIUS::Action::Msf.instance.daemon.status
        rescue
          sleep 10
          puts "No msfdrbd running"
          retry
        end
        startup
        Signal.trap('INT') {
          puts "FIDIUS teardown ..."        
          teardown
          shutdown
        }
        serve
      end

    # overwritten this method from XMLRPC:Server
    # to do exceptionhandling an rpc_method_began and rpc_method_ended
    # callbacks
    def dispatch(methodname, *args)
      for name, obj in @handler
        if obj.kind_of? Proc
          next unless methodname == name
        else
          next unless methodname =~ /^#{name}(.+)$/
          next unless obj.respond_to? $1
          obj = obj.method($1)
        end
        begin
          rpc_method_began
          if check_arity(obj, args.size)
            if @service_hook.nil?
              res = obj.call(*args) 
            else
              res = @service_hook.call(obj, *args)
            end
          end
          rpc_method_ended
          return res
        rescue
          rpc_method_ended
          raise XMLRPC::FaultException.new(109,$!.message+$!.backtrace.inspect)        
        end
      end 
   
      if @default_handler.nil?
        raise XMLRPC::FaultException.new(ERR_METHOD_MISSING, "Method #{methodname} missing or wrong number of parameters!")
      else
        @default_handler.call(methodname, *args) 
      end
    end

    private

      def startup
        FIDIUS.connect_db
        FIDIUS::Action::Msf.instance.start
        FIDIUS::MachineLearning::AgendManager.instance
      end

      def teardown
        FIDIUS::Action::Msf.instance.stop
        FIDIUS.disconnect_db
      end

      def rpc_method_began
#        FIDIUS.connect_db
      end

      def rpc_method_ended
#        FIDIUS.disconnect_db
      end

      def add_handlers
        add_handler("meta",FIDIUS::Server::Handler::Meta.new)
        add_handler("model",FIDIUS::Server::Handler::Model.new)
        add_handler("action",FIDIUS::Server::Handler::Action.new)
        add_handler("decision",FIDIUS::Server::Handler::Decision.new)

        set_default_handler do |name, *args|
          raise XMLRPC::FaultException.new(-99,
            "Method #{name} missing or wrong number of parameters!"
          )
        end
      end

    end # class Server
  end # module RPC
end # module FIDIUS
