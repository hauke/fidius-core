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
  end
end
