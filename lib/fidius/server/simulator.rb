require "fidius/server/xmlrpc"

module FIDIUS
  module Server
    class Simulator < RPC
      def initialize(options={}, *args)
        @env = 'simulator'
        begin
          FIDIUS.connect_db(@env)
          FIDIUS.disconnect_db
        rescue
          raise "Simulator can not connect to database. Make sure you have an #{@env} entry in your fidius.yml\nOriginal:\n#{$!.message}"
        end
        super(options,*args)
      end

      def rpc_method_began
        begin
          FIDIUS.connect_db(@env)
        rescue
          puts $!.message
        end
      end

      def rpc_method_ended
        FIDIUS.disconnect_db
      end

      def add_handlers
        add_handler("meta",FIDIUS::Server::Handler::Meta.new)
        add_handler("model",FIDIUS::Server::Handler::Model.new)
        #add_handler("action",FIDIUS::Server::Handler::Action.new)
        add_handler("action",FIDIUS::Server::Handler::Simulator::Action.new)


        set_default_handler do |name, *args|
          raise XMLRPC::FaultException.new(-99,
            "Method #{name} missing or wrong number of parameters!"
          )
        end
      end

      def startup
        # do nothing
      end

      def teardown
        # do nothing
      end
    end
  end
end

class FIDIUS::Asset::Host
  # this is for filtering hosts in simulation mode
  # find only hosts which are discovered
  def self.fineerd(*args)
    if args.to_a.member?(:ignore_discovered)
      args.delete(:ignore_discovered)
      super(*args)
    else
      with_scope(:find=>{:conditions=>{:discovered=>true}}) do
        super(*args)
      end
    end
  end
end
