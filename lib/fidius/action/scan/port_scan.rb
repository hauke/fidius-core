
module FIDIUS

module Action

require File.join(File.dirname(__FILE__), '..', 'scan')
require 'rex'
require 'tempfile'
require 'nokogiri'
module Scan

class PortScan
  include FIDIUS::Action::Scan

  def initialize target, port_range = nil
    raise ArgumentError, "target isnt a target-Object" unless target.ip
    @target = target
    @port_range = port_range
  end

  def execute 

    raise ArgumentError, "target not set" unless @target
    
    if @port_range
      args = [" -sV -p #{@port_range}", @target.ip]
    else
      args = [" -sV ", @target.ip]
    end
    nmap = Rex::FileUtils.find_full_path("nmap") || Rex::FileUtils.find_full_path("nmap.exe")
    
    if (not nmap)
      puts("The nmap executable could not be found")
      return
    end
    fd = Tempfile.new('xmlnmap')
    fd.binmode
    args.push('-oX', fd.path)
    system([nmap, "nmap"], *args)
    data = ""
    ::File.open(fd.path, 'rb') do |f|
      data = f.read(f.stat.size)
    end
    arguments = {:filename => fd.path}.merge(:data => data)
    # Use a stream parser instead of a tree parser so we can deal with                                                                                                    
    # huge results files without running out of memory.                                                                                                                   
    parser = Rex::Parser::NmapXMLStreamParser.new
    parser.on_found_host = Proc.new { |h|
      h["ports"].each do |p|
        if p["state"] == "open"
          @target.services << FIDIUS::Service.new(p["name"], p["portid"].to_i, p["protocol"])
        end
      end
    end
    f.close
    fd.close(true)
    REXML::Document.parse_stream(data, parser)
    return @target
  end
end

end # module Scan
end # module Action
end # module FIDIUS
