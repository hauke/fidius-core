# -*- coding: utf-8 -*-
module FIDIUS
  module Server
    module Handler
      class Action < FIDIUS::Server::Handler::Base

        # TODO: gebrauchte Funktionen:
        # add_handler("action.reconnaissance") do |host_id|
        def reconnaissance(host_id)
          raise "NOT IMPLEMENTED"
        end

        def single_exploit_host(host_id, exploit_id)
          host = FIDIUS::Asset::Host.find(host_id)
          exploiter = FIDIUS::Action::Exploit::Exploit.instance
          host.interfaces.each do |inter|
            s = exploiter.exploit_interface_with_picked_exploit(inter.id, exploit_id)
            if host.exploited?
              FIDIUS::UserDialog.create_dialog("Completed","Attack was successful on #{host.name}")
              return
            else
              FIDIUS::UserDialog.create_dialog("Completed","Attack was not successful on #{host.name}")
            end
          end
          rpc_method_finish
        end

        def single_exploit_interface(interface_id, exploit_id)
          inter = FIDIUS::Asset::Interface.find(interface_id)
          exploiter = FIDIUS::Action::Exploit::Exploit.instance
          s = exploiter.exploit_interface_with_picked_exploit(inter.id, exploit_id)
          if inter.host.exploited?
            FIDIUS::UserDialog.create_dialog("Completed","Attack was successful on Interface #{inter.ip} (#{inter.host.name})")
          else
            FIDIUS::UserDialog.create_dialog("Completed","Attack was not successful on Interface #{inter.ip} (#{inter.host.name})")
          end
          rpc_method_finish
        end

        def single_exploit_service(service_id, exploit_id)
          service = FIDIUS::Service.find(service_id)
          exploiter = FIDIUS::Action::Exploit::Exploit.instance
          s = exploiter.exploit_service_with_picked_exploit(service_id, exploit_id)
          if service.interface.host.exploited?
            FIDIUS::UserDialog.create_dialog("Completed","Attack was successful on Service #{service.name} (#{service.interface.host.name})")
            return
          else
            FIDIUS::UserDialog.create_dialog("Completed","Attack was not successful on Service #{service.name} (#{service.interface.host.name})")
          end
          rpc_method_finish
        end

        # funktion zum angreifen eines interfaces/hosts mit einem gegebenen exploit
        # bzw als parameter exploit_id, welches AttackModule in der EvasionDB ist
        # FIDIUS::EvasionDB::AttackModule.find(exploit_id)
        #

        def attack_host(host_id)
          host = FIDIUS::Asset::Host.find(host_id)
          exploiter = FIDIUS::Action::Exploit::Exploit.instance
          FIDIUS::Server::TaskManager.new_task "Attack #{host.name}" do |task|
            task.update_progress 30
            host.interfaces.each { |interface|
              result = exploiter.autopwn interface
              if host.exploited?                
                break
              end
            }
            if host.exploited?
              FIDIUS::UserDialog.create_dialog("Completed","Attack was successful on #{host.name}")
            else
              FIDIUS::UserDialog.create_dialog("Completed","Attack was not successful on #{host.name}")
            end
          end
          rpc_method_finish
        end

        def attack_service(service_id)
          service = FIDIUS::Service.find(service_id)
          FIDIUS::Server::TaskManager.new_task "Attack #{service.interface.host.name}" do |task|
            exploiter = FIDIUS::Action::Exploit::Exploit.instance
            result = exploiter.service_autopwn service_id            
            if service.interface.host.exploited?
              FIDIUS::UserDialog.create_dialog("Completed","Attack was successful on Service #{service.name} (#{service.interface.host.name})")
            else
              FIDIUS::UserDialog.create_dialog("Completed","Attack was not successful on Service #{service.name} (#{service.interface.host.name})")
            end
          end
          rpc_method_finish
        end

        def attack_interface(interface_id)
          interface = FIDIUS::Asset::Interface.find(interface_id)
          attack_interface_priv(interface)
          rpc_method_finish
        end

        def attack_ai_host(host_id)
          host = FIDIUS::Asset::Host.find(host_id)
          FIDIUS::Server::TaskManager.new_task "Attack #{host.name}" do |task|
            host.interfaces.each do |interface|
              result = attack_ai_interface_priv(interface)
              next unless result
              FIDIUS::UserDialog.create_dialog("Completed","Attack was successful on #{host.name}")
              return
            end
            FIDIUS::UserDialog.create_dialog("Completed","Attack was not successful on #{host.name}")
          end
          rpc_method_finish
        end

        def attack_ai_service(service_id)
          service = FIDIUS::Service.find(service_id)
          FIDIUS::Server::TaskManager.new_task "Attack #{service.interface.host.name}" do |task|
            result = attack_ai_service_priv(service)
            if result
              FIDIUS::UserDialog.create_dialog("Completed","Attack was successful on Service #{service.name} (#{service.interface.host.name})")
            else
              FIDIUS::UserDialog.create_dialog("Completed","Attack was not successful on Service #{service.name} (#{service.interface.host.name})")
            end
          end
          rpc_method_finish
        end

        def attack_ai_interface(interface_id)
          interface = FIDIUS::Asset::Interface.find(interface_id)
          FIDIUS::Server::TaskManager.new_task "Attack #{interface.host.name}" do |task|
            result = attack_ai_interface_priv(interface)
            if result
              FIDIUS::UserDialog.create_dialog("Completed","Attack was successful on (#{interface.host.name})")
            else
              FIDIUS::UserDialog.create_dialog("Completed","Attack was not successful (#{interface.host.name})")
            end
          end
          rpc_method_finish
        end

        def get_exploits_for_host(host_id)
          host = FIDIUS::Asset::Host.find(host_id)
          exploits = host.find_exploits_for_host
          rpc_method_finish
          exploits
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
                FIDIUS::MachineLearning::AgendManager.instance.agent.decision [h]
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

        def postexploit(sessionID, action, *args)
          FIDIUS::Server::TaskManager.new_task "Postexploit #{sessionID}" do |task|
            FIDIUS::Action::PostExploit.run sessionID, action, *args
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

private

        def attack_interface_priv(interface)
          FIDIUS::Server::TaskManager.new_task "Attack #{interface.host.name}" do |task|
            exploiter = FIDIUS::Action::Exploit::Exploit.instance
            task.update_progress 30

            result = exploiter.autopwn interface
            if interface.host.exploited?
              FIDIUS::UserDialog.create_dialog("Completed","Attack was successful on Interface #{interface.ip} (#{interface.host.name})")
            else
              FIDIUS::UserDialog.create_dialog("Completed","Attack was not successful on Interface #{interface.ip} (#{interface.host.name})")
            end
          end
        end
        
        def attack_ai_interface_priv(interface)
          blacklist = []
          exploiter = FIDIUS::Action::Exploit::Exploit.instance
          while true do
            exploit = FIDIUS::ExploitPicker::exploit_for_interface interface, blacklist
            blacklist << exploit
            break unless exploit
            result = exploiter.exploit_interface_with_picked_exploit(interface.id, exploit.id)
            if result or !interface.host.sessions.empty?
              return true
            end
          end
          return false
        end

        def attack_ai_service_priv(service)
          blacklist = []
          exploiter = FIDIUS::Action::Exploit::Exploit.instance
          while true do
            exploit = FIDIUS::ExploitPicker::exploit_for_service service, blacklist
            blacklist << exploit
            break unless exploit
            result = exploiter.exploit_service_with_picked_exploit(service.id, exploit.id)
            if result or !service.interface.host.sessions.empty?
              return true
            end
          end
          return false
        end

      end
    end
  end
end
