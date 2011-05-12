require "xmlrpc/server"

require "fidius-common"
require "fidius-common/json_symbol_addon"
require "fidius/server/data_changed_patch"
require "fidius/misc/asset_initialiser"

module FIDIUS
  module Server
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
        Signal.trap(:INT) {
          shutdown
        }

        startup
        serve
        teardown
      end

    private
      include FIDIUS::MachineLearning # TODO: include??

      def startup
        FIDIUS.connect_db
        FIDIUS::Action::Msf.instance.start
        FIDIUS.disconnect_db
      end

      def teardown
        FIDIUS::Action::Msf.instance.stop
      end

      def rpc_method_began
        FIDIUS.connect_db
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

        # TODO: gebrauchte Funktionen:
        # add_handler("action.reconnaissance") do |host_id|

        # add_handler("meta.post_exploit_actions") do |session_id|
        # ohne oder für die session 
        # sessionid kann auch nil sein, dann bitte alles
        # gibt hash mit ID, name und beschreibung zurück
        # action.postexploit wird dann mit der ID aufgerufen


        # funktion zum angreifen eines interfaces/hosts mit einem gegebenen exploit 
        # bzw als parameter exploit_id, welches AttackModule in der EvasionDB ist
        # FIDIUS::EvasionDB::AttackModule.find(exploit_id)
        # 

        #  add_handler("action.attack_interface") do |interface_id|

        # TODO: das dieses alle interface probiert
        add_handler("action.attack_host") do |host_id|
          rpc_method_began
          begin
            host = FIDIUS::Asset::Host.find(host_id)

            interface = host.interfaces.first #FIDIUS::Asset::Interface.find(interface_id)
            exploiter = FIDIUS::Action::Exploit::Exploit.instance
            result = exploiter.autopwn interface
            p "exploit result: #{result}"
            if interface.host.exploited?
              FIDIUS::UserDialog.create_dialog("Completed","Attack was sucessful")
            else
              FIDIUS::UserDialog.create_dialog("Completed","Attack was not sucessful")
            end
          rescue
            puts $!.message+":"+$!.backtrace.inspect
          end
          rpc_method_finish
        end

        add_handler("action.scan") do |iprange|
          rpc_method_began
          task = FIDIUS::Task.create_task("Scan #{iprange}")
          Thread.new {
            self_address = nil
            # TODO: multiple scans lead to duplicate hosts in db
            scan = FIDIUS::Action::Scan::PingScan.new(iprange)
            scan = FIDIUS::Action::Scan::ArpScan.new(iprange) unless scan.compatible
            attacker = FIDIUS::Asset::Host.find_by_localhost(true)
            hosts = scan.execute
            if hosts.size > 0
              self_address = FIDIUS::Common.get_my_ip(hosts.first) unless self_address
              hosts.delete(self_address) # do not take scanner host in iteration
              hosts.each do |host|
                # TODO: determine rating?
                h = FIDIUS::Asset::Host.find_or_create_by_ip(host)
                interface = h.find_by_ip host
                h.pivot_host_id = attacker.id if attacker
                h.save
                scan = FIDIUS::Action::Scan::PortScan.new(interface)

                target = scan.execute
                # TODO: not services returned ???
              end
            end
            task.finished
            FIDIUS::UserDialog.create_dialog("Scan Completed","Scan was completed")
          }
          #FIDIUS::UserDialog.create_dialog("Scan started","Scan started. Please wait.")
          rpc_method_finish
        end

        add_handler("action.rate_host") do |host_id,rating|
          rpc_method_began
          h = FIDIUS::Asset::Host.find(host_id)
          h.rating = rating
          h.save
          rpc_method_finish
        end

        add_handler("action.postexploit") do |sessionID, action|
          rpc_method_began
          FIDIUS::Action::PostExploit.run sessionID, action
          rpc_method_finish
        end

        # TODO entweder so oder über generelle task-lösung

        # add_handler("status.browser_autopwn.is_running?") do |lhost|
        # add_handler("status.file_autopwn.is_running?") do |lhost|
        #add_handler("action.browser_autopwn.start") do |lhost|
        #add_handler("action.browser_autopwn.stop") do |lhost|

        add_handler("action.browser_autopwn.start") do |lhost|
          rpc_method_began
          FIDIUS::Action::Exploit::Passive.instance.start_browser_autopwn lhost
          FIDIUS::UserDialog.create_dialog("BrowserAutopwn startet","BrowserAutopwn startet")
          rpc_method_finish
        end

        add_handler("action.file_autopwn.start") do |lhost|
          rpc_method_began
          FIDIUS::Action::Exploit::Passive.instance.start_file_autopwn lhost
          FIDIUS::UserDialog.create_dialog("FileAutopwn startet","FileAutopwn startet")
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
            puts "#{model}.find #{opts.inspect}"
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
