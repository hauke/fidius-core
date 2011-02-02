
module FIDIUS

module Action

require File.join(File.dirname(__FILE__), '..', 'scan')

module Scan

class PingScan
  include FIDIUS::Action::Scan

  def execute
    raise ArgumentError, "target not set" unless @target
    # should execute the nmap scan
    raise NotImplementedError, "not implemented yet"
  end

end

end # module Scan
end # module Action
end # module FIDIUS
