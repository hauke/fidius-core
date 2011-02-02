
module FIDIUS

module Action

require File.join(File.dirname(__FILE__), '..', 'scan')

module Scan

class PortScan
  include FIDIUS::Action::Scan

  def initialize target, port_range = nil
    @target = target
    @port_range = port_range
  end

  def execute
    raise ArgumentError, "target not set" unless @target
    # should execute the nmap scan
    raise NotImplementedError, "not implemented yet"
  end

end

end # module Scan
end # module Action
end # module FIDIUS
