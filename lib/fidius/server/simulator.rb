require "xmlrpc/server"

require "fidius-common"
require "fidius-common/json_symbol_addon"
require "fidius/server/data_changed_patch"
require "fidius/misc/asset_initialiser"

module FIDIUS
  module Server
    class Simulator < ::XMLRPC::Server
    
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
        Signal.trap(:INT) {
          FIDIUS::Action::Msf.instance.stop
          shutdown
        }
        # try to connect to database
        # only to die early if something is strange...
        @env = 'simulator'
        begin
          FIDIUS.connect_db(@env)
          FIDIUS.disconnect_db
        rescue
          raise "Simulator can not connect to database. Make sure you have an #{@env} entry in your fidius.yml\nOriginal:\n#{$!.message}"
        end
        serve
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

      def rpc_method_finish(result="ok")
        rpc_method_ended
        result.to_s
      end

      def add_handlers
        add_handler("meta.data_changed?") do
          rpc_method_began
          rpc_method_finish ActiveRecord::Base.data_changed?
        end

        add_handler("meta.dialog_closed") do
          rpc_method_began
          ud = UserDialog.find :first, :order=>"created_at"
          ud.destroy
          rpc_method_finish
        end

        add_handler("model.clean_hosts") do |opts|
          rpc_method_began
          FIDIUS::Asset::Host.destroy_all
          FIDIUS::UserDialog.create_dialog("Removed all Hosts","All Hosts were removed")
          rpc_method_finish
        end

        add_handler("action.attack_host") do |interface_id|
          rpc_method_began
          interface = FIDIUS::Asset::Interface.find(interface_id)
          if instance.host.exploited? || true
            FIDIUS::UserDialog.create_dialog("Completed","Attack was sucessful")
          else
            FIDIUS::UserDialog.create_dialog("Completed","Attack was not sucessful")
          end
          rpc_method_finish          
        end

        add_handler("action.scan") do |iprange|
          rpc_method_began
          task = FIDIUS::Task.create_task("Scan #{iprange}")
        
          task.finished
          FIDIUS::UserDialog.create_dialog("Scan Completed","Scan was completed")
          rpc_method_finish
        end

        add_handler("action.rate_host") do |host_id,rating|
          rpc_method_began
          h = FIDIUS::Asset::Host.find(host_id)
          h.rating = rating
          h.save
          rpc_method_finish
        end

        add_handler("action.browser_autopwn.start") do |lhost|
          rpc_method_began
          FIDIUS::UserDialog.create_dialog("Browser Autopwn","Browser Autopwn started")
          rpc_method_finish          
        end

        add_handler("action.file_autopwn.start") do |lhost|
          rpc_method_began
          FIDIUS::UserDialog.create_dialog("File Autopwn","File Autopwn started")
          rpc_method_finish          
        end

        add_handler("decision.nn.next") do |opts|
          begin
            res = FIDIUS::MachineLearning.agent.next.id
            FIDIUS::UserDialog.create_yes_no_dialog("Next Target","KI choosed target. Want to attack this host?")
          rescue
            puts $!.inspect
            puts $!.backtrace
          end
          rpc_method_finish(res)
        end

        # TODO REFACTOR THIS
        add_handler("decision.nn.train") do |opts|
          rpc_method_began
          unless $trained
            instances = Array.new
            FIDIUS::Asset::Interface.all.each do |host|
              instances << Instance.new(host, rand(10))
            end
            FIDIUS::MachineLearning.agent.train(instances, 100)
            $trained = true
          end
          rpc_method_finish
        end

        add_handler("model.find") do |opts|
          # moved establish connection here to avoid
          # this nasty RuntimeError: Uncaught exception timeout is not implemented yet in method model.find(2)
          # which is triggered by active_record/connection_adapters/abstract/connection_pool.rb:checkout wait method
          # in ruby 1.9 wait(timeout = nil) waiting for timeout is not implemented... strange ?!
          # UPDATE: connect_db moved to rpc_method_began
          rpc_method_began
          
          raise XMLRPC::FaultException.new(1, "model.find expects at least 2 parameters(modelname, opts)") if opts.size < 2
          model_name = opts.shift
          opts = ActiveSupport::JSON.decode(opts[0])
          res = nil  
          model = nil

          begin
            # search model global
            model = nil
            model_name.split("::").each do |const|
              unless model
                model = Kernel.const_get(const)
              else
                model = model.const_get(const)
              end
            end

          rescue
          end          
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
          # see above nasty timeout is not implemented error
          rpc_method_finish(res.to_xml)
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
