module FIDIUS
  module AssetInitialiser

# TODO: add ipv6
# TODO: add windows support
# TODO: fix mac support
    def self.addLocalAddresses
      os = IO.popen('uname'){ |f| f.readlines[0] }
      name = IO.popen('hostname'){ |f| f.readlines[0] }
      arch = IO.popen('uname -m'){ |f| f.readlines[0] }
      addres = get_interfaces4
      FIDIUS.connect_db
      host = nil
      addres.each do |mac, addr, bcast, mask|
        next if addr == "127.0.0.1"
        unless host
          host = FIDIUS::Asset::Host.find_or_create_by_ip_and_mac(addr, mac)
          host.localhost = true;
          host.os_name = os.strip;
          host.name = name.strip;
          host.arch = arch.strip;
          host.save
        end

        interface = host.find_or_create_by_ip_and_mac addr, mac
        interface.ip_mask = mask
        interface.ip_ver = 4
        interface.save
      end
      FIDIUS.disconnect_db
    end

    def self.get_interfaces4
      # require 'rbconfig'; Config::CONFIG['host_os'] =~ /linux/ bzw. /mswin|mingw/ /darwin/ 
      os = IO.popen('uname'){ |f| f.readlines[0] }
      if os.strip.downcase == "linux" || os.strip.downcase == "darwin"
        if File.exists?('/etc/debian_version')
          cmd = '/sbin/ifconfig' 
        else
          cmd = IO.popen('which ifconfig'){ |f| f.readlines[0] }
          raise RuntimeError.new("ifconfig not in PATH") unless !cmd.nil?
        end
        if RUBY_VERSION.to_f < 1.9
          ifconfig = IO.popen("LANG=C #{cmd}"){ |f| f.readlines.join }
        else
          ifconfig = IO.popen([{"LANG" => "C"}, cmd.strip]){ |f| f.readlines.join }
        end

        return ifconfig.scan(/(?:HWaddr ([a-f0-9:]*)?)?\s*inet addr:([0-9\.]*)\s*(?:Bcast:([0-9\.]*)\s*?)?Mask:([0-9\.]*)/)
        #TODO: IPv6: ifconfig.scan(/inet6 addr: ([0-9a-f:]*)\/([0-9]{1,2})/)
        #ip.inspect.scan(/\/([a-f0-9\.\:]*)>/).flatten
      end
      return []
    end
    
    def self.initializePrelude
      return unless FIDIUS.config['prelude']
      FIDIUS.connect_db
      h = FIDIUS::Asset::Host.find_or_create_by_ip(FIDIUS.config['prelude']['host'])
      h.ids = true;
      h.save
      FIDIUS.disconnect_db
    end
    
    addLocalAddresses
    initializePrelude
    
  end
end
