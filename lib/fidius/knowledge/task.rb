module FIDIUS
  class Task < ActiveRecord::Base
    def self.create_task(name)
      Task.create(:name=>name,:progress=>0)
    end

    def finished
      self.completed=true
      self.progress=100
      self.save
    end

    def update_progress(p)
      self.progress = p
      self.save
    end

    def add_progress(v)
      self.progress += v.to_i
      self.save
    end
  end
end
