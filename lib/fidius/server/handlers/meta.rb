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
      end
    end
  end
end 
