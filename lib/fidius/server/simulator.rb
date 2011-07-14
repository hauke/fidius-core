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
        @@meta = FIDIUS::Server::Handler::Simulator::Meta.new
        puts "HALLO: @@meta: #{@@meta}"
        @@model = FIDIUS::Server::Handler::Model.new
        @@action = FIDIUS::Server::Handler::Simulator::Action.new

        add_handler("meta",@@meta)
        add_handler("model",@@model)
        add_handler("action",@@action)


        set_default_handler do |name, *args|
          raise XMLRPC::FaultException.new(-99,
            "Method #{name} missing or wrong number of parameters!"
          )
        end
      end

      def self.action
        @@action
      end

      def self.meta
        @@meta
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
  def self.fin2d(*args)
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
