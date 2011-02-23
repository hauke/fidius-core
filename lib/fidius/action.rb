module FIDIUS
  module Action
    include FIDIUS::Loudness
    
    autoload :Scan, 'fidius/action/scan'
    autoload :Exploit, 'fidius/action/exploit'
        
  end # module Action
end # module FIDIUS
