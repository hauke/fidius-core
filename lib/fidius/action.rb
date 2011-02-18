class FIDIUS
  module Action

    autoload :Scan, 'fidius/action/scan'

    def get_loudness
      raise NotImplementedError, "method must be overwritten by subclass"
    end
    
  end #module Action
end # module FIDIUS
