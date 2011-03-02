module FIDIUS
  module Action
    include FIDIUS::Loudness
    
    autoload :Scan,    'fidius/action/scan'
    autoload :Exploit, 'fidius/action/exploit'
    autoload :Msf,     'fidius/action/msf'
    
    def msf_framework
      FIDIUS::Action::Msf.instance.framework
    end
    module_function :msf_framework
    
  end # module Action
end # module FIDIUS
