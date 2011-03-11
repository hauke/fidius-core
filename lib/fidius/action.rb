# TODO: does EVERY action need these Rex classes?

require 'fidius/misc/nmap_xml' # copied from msf/lib
require 'fidius/misc/file'     # copied from msf/lib
require 'fidius/misc/compat'   # copied from msf/lib

module FIDIUS
  module Action
    include FIDIUS::Loudness
    
    autoload :Scan,    'fidius/action/scan'
    autoload :Exploit, 'fidius/action/exploit'
    autoload :Session, 'fidius/action/session'
    autoload :Msf,     'fidius/action/msf'
    
    # Gets the singleton instance of the DRB wrapped Metasploit
    # framework.
    #
    # @return [Msf::Simple::Framework]  The Metasploit framework.
    def msf_framework
      FIDIUS::Action::Msf.instance.framework
    end
    module_function :msf_framework
    
  end # module Action
end # module FIDIUS
