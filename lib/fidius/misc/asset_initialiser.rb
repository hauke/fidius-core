module FIDIUS
  module AssetInitialiser

# TODO: add ipv6
# TODO: add windows support
    def self.addLocalAddresses
      os = IO.popen('uname'){ |f| f.readlines[0] }
      name = IO.popen('hostname'){ |f| f.readlines[0] }
      arch = IO.popen('uname -m'){ |f| f.readlines[0] }
      address = get_interfaces4
      
      FIDIUS.connect_db
      host = nil
      address.each do |mac, addr, bcast, mask|
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
      
      unless address.length > 0 && host
        dummy_ip = "127.0.0.1"
        dummy_mac = "00:11:22:33:44:55"
        host = FIDIUS::Asset::Host.find_or_create_by_ip_and_mac(dummy_ip, dummy_mac)
        host.localhost = true;
        host.os_name = "windows";
        host.name = "dummy";
        host.arch = "x86";
        host.save
        
        interface = host.find_or_create_by_ip_and_mac dummy_ip, dummy_mac
        interface.ip_mask = "255.0.0.0"
        interface.ip_ver = 4
        interface.save
      end
      
      FIDIUS.disconnect_db
    end

    def self.get_interfaces4
      # require 'rbconfig'; Config::CONFIG['host_os'] =~ /linux/ bzw. /mswin|mingw/ /darwin/ 
      return_array = []
      os = IO.popen('uname'){ |f| f.readlines[0] }
      if os.strip.downcase == "linux" || os.strip.downcase == "darwin"
        if File.exists?('/sbin/ifconfig')
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
          if os.strip.downcase == "darwin"
            tmp_ary = ifconfig.scan(/ether\s([a-f0-9:]*)[\s\w:%]*inet\s([0-9\.]*)\s*netmask\s(0x[a-f0-9]*)\s*broadcast\s([0-9\.]*)/)
            tmp_ary.each {|mac, addr, mask, bcast|
              return_array<<[mac,addr,bcast,hex_to_ip(mask)]
            }
          else
            return_array = ifconfig.scan(/(?:HWaddr ([a-f0-9:]*)?)?\s*inet addr:([0-9\.]*)\s*(?:[(Bcast)|(P\-t\-P)]+:([0-9\.]*)\s*?)?Mask:([0-9\.]*)/)
          end
        #TODO: IPv6: ifconfig.scan(/inet6 addr: ([0-9a-f:]*)\/([0-9]{1,2})/)
        #ip.inspect.scan(/\/([a-f0-9\.\:]*)>/).flatten
      end
      return return_array;
    end
    
    def self.hex_to_ip hex
      hex = hex.sub("0x",'')
      hex.scan(/../).map {|i| i.to_i(16)}.join(".")
    end
    def self.initializePrelude
      return unless FIDIUS.config['prelude'] and FIDIUS.config['prelude']['host']
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
