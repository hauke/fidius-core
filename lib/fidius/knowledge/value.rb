module FIDIUS

  # simple relevance implementation
  class Relevance
    
    attr_acessor :count_files, :disk_usage, :interfaces, :num_connections
    
    def initialize 
      @count_files = 0 # num Files in /home 
      @disk_usage = 0.0 # num GB used
      @interfaces = 0 # num interfaces
      @num_connections = 0 # num connections
    end
    
    def relevance
      @count_files + @disk_usage + @interfaces + @num_connections
    end

  end # Relevance

end # FIDIUS
