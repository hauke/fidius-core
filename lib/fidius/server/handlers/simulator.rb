module FIDIUS
  module Server
    module Handler
      module Simulator
        class Action < FIDIUS::Server::Handler::Base
          def attack_host(host_id)
            host = FIDIUS::Asset::Host.find(host_id)
            FIDIUS::Server::TaskManager.new_task "Attack #{host.name}" do |task|
              task.update_progress(10)
              sleep 10
              
              #interface = host.interfaces.first #FIDIUS::Asset::Interface.find(interface_id)
              host.sessions << FIDIUS::Session.create(:service_id=>host.interfaces.first.services.first.id)
              if host.exploited? || true
                FIDIUS::UserDialog.create_dialog("Completed","Attack was sucessful")
              else
                FIDIUS::UserDialog.create_dialog("Completed","Attack was not sucessful")
              end
            end
            rpc_method_finish          
          end

          def reconnaissance(host_id)
            host = FIDIUS::Asset::Host.find(host_id)
            FIDIUS::Server::TaskManager.new_task "Reconnaissance #{host.name}" do |task|
              sleep 40
              task.update_progress(10)
              sleep 10
              task.update_progress(20)

              FIDIUS::Asset::Host.find(:all,:ignore_discovered,:conditions=>({:pivot_host_id=>host.id})).each do |host|
                if !host.discovered
                  host.discovered = true
                  host.save
                end
              end
              task.finished
              FIDIUS::UserDialog.create_dialog("Reconnaissance Completed","Reconnaissance was completed")
            end
            rpc_method_finish
          end

          def scan(iprange)
            FIDIUS::Server::TaskManager.new_task "Scan #{iprange}" do |task|
              attacker = FIDIUS::Asset::Host.find_by_localhost(true)
              net = IPAddr.new(iprange)
              FIDIUS::Asset::Host.find(:all,:ignore_discovered,:conditions=>({:pivot_host_id=>attacker.id})).each do |host|
                host.interfaces.each do |interface|
                  if net.include?(interface.ip)
                    host.discovered = true
                    host.save
                  end
                end
              end
              sleep(40)
              FIDIUS::UserDialog.create_dialog("Scan Completed","Scan was completed")
            end
            rpc_method_finish
          end

          def postexploit(sessionID, action)
            rpc_method_finish
          end

          def browser_autopwn_start(lhost)
            FIDIUS::UserDialog.create_dialog("BrowserAutopwn startet","BrowserAutopwn startet")
            rpc_method_finish
          end

          def file_autopwn_start(lhost)
            FIDIUS::UserDialog.create_dialog("FileAutopwn startet","FileAutopwn startet")
            rpc_method_finish
          end

        end#Action
      end#Simulator
    end#Handler
  end#Server
end#FIDIUS
