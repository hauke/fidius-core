# coding:utf-8
require 'test_helper_fidius'
require 'fidius/server/task_manager'

class TestTaskManager < FIDIUS::Test
  def test_simple_creation
    assert_equal 0, FIDIUS::Server::TaskManager.active_task_count
    t = FIDIUS::Server::TaskManager.new_task "Scan something" do
      sleep 10
    end
    assert_equal 1, FIDIUS::Server::TaskManager.active_task_count
    sleep 20
    assert FIDIUS::Server::TaskManager.completed?(t)
    FIDIUS::Server::TaskManager.remove_finished_tasks
    assert_equal 0, FIDIUS::Server::TaskManager.active_task_count
    assert_equal 0, FIDIUS::Task.count(:all)
  end

  def test_kill_task
    assert_equal 0, FIDIUS::Server::TaskManager.active_task_count
    t = FIDIUS::Server::TaskManager.new_task "Scan something" do
      sleep 10
    end
    sleep 3
    assert_equal 1, FIDIUS::Server::TaskManager.active_task_count
    FIDIUS::Server::TaskManager.kill_task(t)

    assert !FIDIUS::Server::TaskManager.completed?(t)
    assert_equal 0, FIDIUS::Server::TaskManager.active_task_count
    assert_equal 0, FIDIUS::Task.count(:all)
  end

  def test_start_multiple
    assert_equal 0, FIDIUS::Server::TaskManager.active_task_count
    t = FIDIUS::Server::TaskManager.new_task "Scan something" do
      sleep 10
    end
    t = FIDIUS::Server::TaskManager.new_task "Scan something" do
      sleep 10
    end
    t = FIDIUS::Server::TaskManager.new_task "Scan something" do
      sleep 10
    end
    assert_equal 3, FIDIUS::Server::TaskManager.active_task_count    
    assert_equal 3, FIDIUS::Task.count(:all)
    sleep 15    
    assert_equal 0, FIDIUS::Server::TaskManager.active_task_count    
    assert_equal 3, FIDIUS::Task.count(:all)
  end

  def test_set_progress
    t = FIDIUS::Server::TaskManager.new_task "Scan something" do |task|
      task.update_progress(10)
      sleep 10
    end
    sleep 5
    assert_equal 10, t.progress
    sleep 10  
    assert_equal 0, FIDIUS::Server::TaskManager.active_task_count    
    FIDIUS::Server::TaskManager.remove_finished_tasks
    assert_equal 0, FIDIUS::Task.count(:all)
    
  end
end
