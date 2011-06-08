module FIDIUS
  module Server
    module Handler
      class Action < FIDIUS::Server::Handler::Base


        # TODO: gebrauchte Funktionen:
        # add_handler("action.reconnaissance") do |host_id|
        def reconnaissance(host_id)
          raise "NOT IMPLEMENTED"
        end
        # add_handler("meta.post_exploit_actions") do |session_id|
        # ohne oder für die session 
        # sessionid kann auch nil sein, dann bitte alles
        # gibt hash mit ID, name und beschreibung zurück
        # action.postexploit wird dann mit der ID aufgerufen

        def single_exploit(host_id, exploit_id)
          host = FIDIUS::Asset::Host.find(host_id)
          host.interfaces.each do |inter|
            FIDIUS::Action::Exploit::Exploit.exploit_interface_with_picked_exploit(inter.id, exploit_id)
          end
          rpc_method_finish
        end
        # funktion zum angreifen eines interfaces/hosts mit einem gegebenen exploit 
        # bzw als parameter exploit_id, welches AttackModule in der EvasionDB ist
        # FIDIUS::EvasionDB::AttackModule.find(exploit_id)
        # 

        #  add_handler("action.attack_interface") do |interface_id|

        # TODO: das dieses alle interface probiert
        def attack_host(host_id)
          host = FIDIUS::Asset::Host.find(host_id)
          FIDIUS::Server::TaskManager.new_task "Attack #{host.name}" do |task|
            interface = host.interfaces.first #FIDIUS::Asset::Interface.find(interface_id)
            exploiter = FIDIUS::Action::Exploit::Exploit.instance
            task.update_progress 30

            result = exploiter.autopwn interface
            p "exploit result: #{result}"
            if interface.host.exploited?
              FIDIUS::UserDialog.create_dialog("Completed","Attack was sucessful")
            else
              FIDIUS::UserDialog.create_dialog("Completed","Attack was not sucessful")
            end
          end
          rpc_method_finish
        end

        def scan(iprange)
          FIDIUS::Server::TaskManager.new_task "Scan #{iprange}" do |task|
            self_address = nil
            # TODO: multiple scans lead to duplicate hosts in db
            task.update_progress 10
            scan = FIDIUS::Action::Scan::PingScan.new(iprange)
            scan = FIDIUS::Action::Scan::ArpScan.new(iprange) unless scan.compatible
            attacker = FIDIUS::Asset::Host.find_by_localhost(true)
            task.update_progress 20
            hosts = scan.execute
            if hosts.size > 0
              self_address = FIDIUS::Common.get_my_ip(hosts.first) unless self_address
              hosts.delete(self_address) # do not take scanner host in iteration
              progress_step = 80/hosts.size
              hosts.each do |host|
                # TODO: determine rating?
                h = FIDIUS::Asset::Host.find_or_create_by_ip(host)
                interface = h.find_by_ip host
                h.pivot_host_id = attacker.id if attacker
                h.save
                scan = FIDIUS::Action::Scan::PortScan.new(interface)

                target = scan.execute
                # TODO: not services returned ???
                task.add_progress progress_step
              end
            end
            FIDIUS::UserDialog.create_dialog("Scan Completed","Scan was completed")
          end
          rpc_method_finish
        end

        def rate_host(host_id,rating)
          h = FIDIUS::Asset::Host.find(host_id)
          h.rating = rating
          h.save
          rpc_method_finish
        end

        def postexploit(sessionID, action)
          FIDIUS::Server::TaskManager.new_task "Postexploit #{sessionID}" do |task|
            FIDIUS::Action::PostExploit.run sessionID, action
          end
          rpc_method_finish
        end

        # TODO entweder so oder über generelle task-lösung

        # add_handler("status.browser_autopwn.is_running?") do |lhost|
        # add_handler("status.file_autopwn.is_running?") do |lhost|
        #add_handler("action.browser_autopwn.start") do |lhost|
        #add_handler("action.browser_autopwn.stop") do |lhost|

        def browser_autopwn_start(lhost)
 
          FIDIUS::Server::TaskManager.new_task "BrowserAutopwn" do |task|
            # TODO: browser autopwn should not leaf this block
            # task is immediatly finished 
            # should block as long as runtime
            FIDIUS::Action::Exploit::Passive.instance.start_browser_autopwn lhost
          end
          FIDIUS::UserDialog.create_dialog("BrowserAutopwn startet","BrowserAutopwn startet")
          rpc_method_finish
        end

        def file_autopwn_start(lhost)
          FIDIUS::Server::TaskManager.new_task "FileAutopwn" do |task|
            # TODO: file autopwn should not leaf this block
            # task is immediatly finished 
            FIDIUS::Action::Exploit::Passive.instance.start_file_autopwn lhost
          end
          FIDIUS::UserDialog.create_dialog("FileAutopwn startet","FileAutopwn startet")
          rpc_method_finish
        end

      end
    end
  end
end 
