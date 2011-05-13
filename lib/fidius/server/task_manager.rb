# coding:utf-8
module FIDIUS
  module Server
    module TaskManager
      @@running_tasks = {}

      def self.new_task(title, &block)
        raise "no task given" unless block
        task = FIDIUS::Task.create_task(title)        
        t = Thread.new {
          begin
            block.call(task)
            task.finished
            @@running_tasks.delete(task.id) if @@running_tasks[task.id]
          rescue
            begin
              puts "TaskManager fetched in Thread: "+$!.message+":"+$!.backtrace.to_s
              task.error = $!.message+":"+$!.backtrace.to_s.gsub("'","").gsub("`","")
              task.save
            rescue
              puts "TaskManager fetched in Thread: "+$!.inspect
            end
          end
        }
        @@running_tasks = @@running_tasks.merge({task.id=>t})
        task
      end

      def self.active_task_count
        @@running_tasks.size.to_i
      end

      def self.kill_task(task)
        raise "argument must be type of FIDIUS::Task but was #{task.class}" unless task.class == FIDIUS::Task
        @@running_tasks[task.id].kill if @@running_tasks[task.id]
        @@running_tasks.delete(task.id)
        task.destroy
        nil
      end

      def self.remove_finished_tasks
        FIDIUS::Task.destroy_all({:completed=>true})
      end

      def self.completed?(task)
        return false if task.destroyed?
        task.completed
      end
    end
  end
end
