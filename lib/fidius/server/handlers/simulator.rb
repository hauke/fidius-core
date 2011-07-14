module FIDIUS
  module Server
    module Handler
      module Simulator

        class Meta < FIDIUS::Server::Handler::Meta
          def new_pentest
            FIDIUS::Asset::Host.all.each do |host|
              next if host.localhost
              host.discovered = false
              host.save
            end
            FIDIUS::ActionLog.destroy_all
            FIDIUS::Task.all.each do |t|
              FIDIUS::Server::TaskManager.kill_task(t)
            end
            FIDIUS::Task.destroy_all
            FIDIUS::Session.destroy_all
            FIDIUS::UserDialog.destroy_all
            rpc_method_finish
          end
        end

        class Action < FIDIUS::Server::Handler::Base
          def attack_host(host_id)
            host = FIDIUS::Asset::Host.find(host_id)
            FIDIUS::Server::TaskManager.new_task "Attack #{host.name_or_ip}" do |task|
              task.update_progress(10)
              sleep 3
              
              #interface = host.interfaces.first #FIDIUS::Asset::Interface.find(interface_id)
              host.sessions << FIDIUS::Session.create(:service_id=>host.interfaces.first.services.first.id)
              if host.exploited? || true
                ActionLog.log("Sucessful Exploit",host_id)
                FIDIUS::UserDialog.create_dialog("Completed","Attack was sucessful")
              else
                ActionLog.log("No Sucessful Exploit",host_id)
                FIDIUS::UserDialog.create_dialog("Completed","Attack was not sucessful")
              end
            end
            puts "HALLO SIMULATOR create_log_for_action"
            rpc_method_finish
          end

          def attack_service(service_id)
            FIDIUS::UserDialog.create_dialog("Completed","Attack was sucessful #{service_id}")          
          end        

          def reconnaissance(host_id)
            host = FIDIUS::Asset::Host.find(host_id)
            FIDIUS::Server::TaskManager.new_task "Reconnaissance #{host.name_or_ip}" do |task|
              sleep 3
              task.update_progress(10)
              sleep 3
              task.update_progress(20)

              FIDIUS::Asset::Host.find(:all,:ignore_discovered,:conditions=>({:pivot_host_id=>host.id})).each do |host|
                if !host.discovered
                  host.discovered = true
                  host.save
                end
              end
              task.finished
              ActionLog.log("Reconnaissance #{host.name_or_ip}",host_id)
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
              sleep(5)
              ActionLog.log("Scan #{iprange}")
              FIDIUS::UserDialog.create_dialog("Scan Completed","Scan was completed")
            end
            create_log_for_action(ActionMock.new)
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
