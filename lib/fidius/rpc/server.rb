require "xmlrpc/server"
require "fidius/misc/json_symbol_addon.rb"

module FIDIUS
  module RPC
    class Server < ::XMLRPC::Server
      def initialize(options={}, *args)

        defaults = {
          :port => 8080,
          :host => '127.0.0.1',
          :max_connections => 4,
          :stdlog => $stdout,
          :audit => true,
          :debug => true
        }
        options = defaults.merge options
        super(
          options[:port],
          options[:host],
          options[:max_connections],
          options[:stdlog],
          options[:audit],
          options[:debug],
          *args
        )
        add_handlers
        set_service_hook do |obj, *args|
          # XXX: here might be a nice entry point to avoid code dublettes
          #      like in line 38/42
          obj.call(*args)
        end
        Signal.trap(:INT) { shutdown }
        serve
      end
      
    private
    
      def add_handlers
        add_handler("model.find") do |opts|
          # moved establish connection here to avoid
          # this nasty RuntimeError: Uncaught exception timeout is not implemented yet in method model.find(2)
          # which is triggered by active_record/connection_adapters/abstract/connection_pool.rb:checkout wait method
          # in ruby 1.9 wait(timeout = nil) waiting for timeout is not implemented... strange ?!
          FIDIUS.connect_db
          
          raise XMLRPC::FaultException.new(1, "model.find expects at least 2 parameters(modelname, opts)") if opts.size < 2
          model_name = opts.shift
          opts = ActiveSupport::JSON.decode(opts[0])
          res = nil  
          model = nil
          
          begin
            # search model in FIDIUS namespace
            model = Kernel.const_get("FIDIUS").const_get(model_name)
          rescue 
          end
          begin
            # search model in FIDIUS::Asset namespace
            model = Kernel.const_get("FIDIUS").const_get("Asset").const_get(model_name)
          rescue 
          end
          raise XMLRPC::FaultException.new(2, "Class #{model_name} was not found") unless model
          begin #save execution of find method
            res = model.find(*opts)
          rescue
            # doesnt matter, object not found will be thrown
          end
          unless res
            raise XMLRPC::FaultException.new(3, "object was not found")
          end
          xml_response = res.to_xml
          
          # see above nasty timeout is not implemented error
          FIDIUS.disconnect_db
          xml_response
        end
        
        set_default_handler do |name, *args|
          raise XMLRPC::FaultException.new(-99,
            "Method #{name} missing or wrong number of parameters!"
          )
        end
      end
    
    end # class Server
  end # module RPC
end # module FIDIUS

