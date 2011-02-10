module FIDIUS

module Action

require File.join(File.dirname(__FILE__), '..', 'scan')

module Scan

class ARPScan
  include FIDIUS::Action::Scan

  # returns an array of hosts (which are up) in a given subnet

  def initialize subnet
    raise ArgumentError, "target not set" unless subnet
    @subnet = subnet
    @hosts = []
  end


  def execute
    args = ["-PR", @subnet]
    nmap = Rex::FileUtils.find_full_path("nmap") || Rex::FileUtils.find_full_path("nmap.exe")
    if (not nmap)
      puts("The nmap executable could not be found")
      return
    end

    fd = Tempfile.new('xmlnmap')
    fd.binmode
    args.push('-oX', fd.path)
    raise "Nmap arp-scan failed" unless (system("#{nmap} #{args.join(' ')}"))
    data = ""
    ::File.open(fd.path, 'rb') do |f|
      data = f.read(f.stat.size)
    end
    arguments = {:filename => fd.path}.merge(:data => data)
    puts fd.path
    parser = Rex::Parser::NmapXMLStreamParser.new
    parser.on_found_host = Proc.new do |h|
      # all hosts are down :/ TODO: FIXME
      if h["status"] == "up"
          puts h["addrs"]["ipv4"]
         @hosts << h["addrs"]["ipv4"]
      end
    end
    system("cp #{fd.path} /home/chroiss/Desktop/")
    fd.close(true)
    REXML::Document.parse_stream(data, parser)
    return @hosts
  end

end

end # module Scan
end # module Action
end # module FIDIUS

