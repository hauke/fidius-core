class FIDIUS::Action::Scan::ARPScan
  include FIDIUS::Action::Scan

  def execute
    raise ArgumentError, "target not set" unless @target
    # should execute the nmap scan
    raise NotImplementedError, "not implemented yet"
  end

end

