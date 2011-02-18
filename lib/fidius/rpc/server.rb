require "xmlrpc/server"

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
        add_handler("model.host.find") do |opts|
          find FIDIUS::Asset::Host, *opts
        end
        
        add_handler("model.service.find") do |opts|
          # find FIDIUS::Service, *opts
          # TODO: not an ActiveRecord yet
          [].to_xml
        end
        
        set_default_handler do |name, *args|
          raise XMLRPC::FaultException.new(-99,
            "Method #{name} missing or wrong number of parameters!"
          )
        end
      end
      
      def find model, *opts
        res = nil  
        if opts[0].to_i > 0 # id
          opts[0] = opts[0].to_i
          res = model.find *opts
        else # first or last or all
          opts[0] = opts[0].to_sym
          res = model.find *opts
        end
        unless res
          raise XMLRPC::FaultException.new(1, "object was not found")
        end
        res.to_xml
      end
    
    end # class Server
  end # module RPC
end # module FIDIUS

