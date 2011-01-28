
module FIDIUS

module Action

require File.join(File.dirname(__FILE__), '..', 'scan')

module Scan

class ARPScan
  include FIDIUS::Action::Scan

  def execute
    raise ArgumentError, "host is not set" unless @target_host
    # should execute the nmap scan
    raise NotImplementedError, "not implemented yet"
  end

end

end # module Scan
end # module Action
end # module FIDIUS
