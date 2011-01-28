
module FIDIUS

require File.join(File.dirname(__FILE__), '..', 'action')

module Action

module Scan
  
  #
  # initilizing the scan
  #
  def init_scan
    # should save the current state of msf host list
    raise NotImplementedError, "method must be implemented by subclass"
  end

  def check_param host
    return true if host.is_a FIDIUS::Asset::Host
    nil
  end

  # 
  def get_success
    # should return a list of hosts which are new after scan
    raise NotImplementedError, "method must be implemented by subclass"
  end

  def initialize host
    @target_host = host
  end

  def loudness
    raise NotImplementedError, "method must be implemented by subclass"
  end
end

end
end
