module FIDIUS
  module Server
    module Handler
      class Meta < FIDIUS::Server::Handler::Base
        def data_changed?
          rpc_method_finish ActiveRecord::Base.data_changed?
        end

        def dialog_closed
          ud = UserDialog.find :first, :order=>"created_at"
          ud.destroy
          rpc_method_finish
        end

        def remove_finished_tasks
          FIDIUS::Server::TaskManager.remove_finished_tasks
          rpc_method_finish
        end

        def kill_task(task_id)
          puts "kill_task"
          task = FIDIUS::Task.find(task_id)
          #if !task.finished
            puts "FIDIUS::Server::TaskManager.kill_task(#{task.inspect})"
            FIDIUS::Server::TaskManager.kill_task(task)
          #else
          #  task.destroy
          #end
          rpc_method_finish
        end

        def post_exploit_actions(sessionID = nil)
          result = FIDIUS::Action::PostExploit.get_exploit_names sessionID
          rpc_method_finish
          result
        end

        def running_passive_actions
          result = FIDIUS::Action::Exploit::Passive.instance.running_actions
          rpc_method_finish
          result
        end

        def exec_msf_command(cmd)
          FIDIUS::Action::Msf.instance.daemon.exec_msf_command cmd
        end

        def new_pentest
          FIDIUS::Asset::Host.all.each {|h| h.destroy}
          FIDIUS::Asset::Interface.all.each {|i| i.destroy}
          FIDIUS::Service.all.each {|se| se.destroy}
          FIDIUS::Task.all.each {|t| t.destroy}
          FIDIUS::UserDialogs.each {|u| u.destroy}
          FIDIUS::Action::Session.close_all_sessions
        end
      end
    end
  end
end
