require "xmlrpc/server"
require "fidius/misc/json_symbol_addon.rb"

module FIDIUS
  module RPC
    class Server < ::XMLRPC::Server
    
      def initialize(options={}, *args)
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
        Signal.trap(:INT) { shutdown }
        serve
      end
      
    private
      include FIDIUS::MachineLearning
      def add_handlers
        add_handler("model.clean_hosts") do |opts|
          begin
            FIDIUS.connect_db
            FIDIUS::Asset::Host.destroy_all
            FIDIUS.disconnect_db
          rescue
          end
          "ok"          
        end
        # TODO REFACTOR THIS
        add_handler("action.scan") do |opts|
          # TODO

            FIDIUS.connect_db
            puts "scan dummy| #{FIDIUS::Asset::Host.all.size} Hosts in DB"
            if (FIDIUS::Asset::Host.all.size == 0)
              ["192.168.0.2","192.168.0.88","192.168.0.16"].each do |ip|
                h = FIDIUS::Asset::Host.create(:name => "KEEEEEKS", :ip => ip)
                h.services << FIDIUS::Service.new(:name => "ssh",    :port => 22,   :proto => "tcp")
                h.services << FIDIUS::Service.new(:name => "vnc",    :port => 5900, :proto => "tcp")
                h.services << FIDIUS::Service.new(:name => "smtp",   :port => 25,   :proto => "tcp")
                h.services << FIDIUS::Service.new(:name => "domain", :port => 53,   :proto => "udp")
                h.save
              end
            end
            FIDIUS.disconnect_db
          "ok"
        end

        add_handler("decision.nn.next") do |opts|
          FIDIUS.connect_db
          #res = FIDIUS::Asset::Host.first.id
          begin
            puts "next.id"
            res = FIDIUS::MachineLearning.agent.next.id
            puts "res ist: #{res}"
          rescue
            puts $!.inspect
            puts $!.backtrace
          end
          #puts "result: #{res}"
          FIDIUS.disconnect_db
          "#{res}"
        end
        # TODO REFACTOR THIS
        add_handler("decision.nn.train") do |opts|
          FIDIUS.connect_db
          #if FIDIUS::Asset::Host.all.size == 0
            # TODO replace dummy hosts
            #h1 = FIDIUS::Asset::Host.find_or_create_by_name("KEEEEEKS")
            #if h1.services.size == 0
            #  h1.services = []
            #  h1.services << FIDIUS::Service.create(:name => "ssh", :port => 22, :proto => "tcp")
            #  h1.services << FIDIUS::Service.create(:name => "vnc", :port => 5900, :proto => "tcp")
            #  h1.services << FIDIUS::Service.create(:name => "smtp", :port => 25, :proto => "tcp")
            #  h1.services << FIDIUS::Service.create(:name => "domain", :port => 53, :proto => "udp")
            #end
            #inst = Instance.new(h1, 2)
            #h2 = FIDIUS::Asset::Host.find_or_create_by("KEEEEEKS2")
            #if h2.services.size == 0
            #  h2.services = []
            #  h2.services << FIDIUS::Service.create(:name => "ssh", :port => 22, :proto => "tcp")
            #  h2.services << FIDIUS::Service.create(:name => "vnc", :port => 5900, :proto => "tcp")
            #  h2.services << FIDIUS::Service.create(:name => "smtp", :port => 25, :proto => "tcp")
            #  h2.services << FIDIUS::Service.create(:name => "domain", :port => 53, :proto => "udp")
            #end
            #inst2 = Instance.new(h2, 3)
            unless $trained
              instances = Array.new
              FIDIUS::Asset::Host.all.each do |host|
                instances << Instance.new(host, rand(10))
              end
              FIDIUS::MachineLearning.agent.train(instances, 100)
              $trained = true
            end
          #end
          FIDIUS.disconnect_db
          "ok"
        end

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

