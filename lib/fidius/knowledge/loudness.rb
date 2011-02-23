module FIDIUS
  module Loudness

    SILENT = 0
    VERY_VERY_LOUD = 100

    def self.<
        raise NotImplementedError, "not implemented yet"
    end

    def self.>
        raise NotImplementedError, "not implemented yet"
    end
    
    def get_loudness
      raise NotImplementedError, "method must be overwritten by subclass"
    end

  end # module Loudness
end # module FIDIUS
