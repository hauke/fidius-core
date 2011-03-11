module FIDIUS
  module AssertInitialiser

    def self.addLocalAddresses
      FIDIUS.connect_db
      addres = get_interfaces
      addres.each do |addr|
        FIDIUS::Asset::Host.find_or_create_by_ip(addr) unless addr == "127.0.0.1"
      end
      FIDIUS.disconnect_db
    end

    def self.get_interfaces
      # require 'rbconfig'; Config::CONFIG['host_os'] =~ /linux/ bzw. /mswin|mingw/ /darwin/ 
      os = IO.popen('uname'){ |f| f.readlines[0] }
      if os.strip.downcase == "linux" || os.strip.downcase == "darwin"
        cmd = IO.popen('which ifconfig'){ |f| f.readlines[0] }
        raise RuntimeError.new("ifconfig not in PATH") unless !cmd.nil?
        ifconfig = IO.popen([{"LANG" => "C"}, cmd.strip]){ |f| f.readlines.join }
      
        return ifconfig.scan(Regexp.new("inet addr:((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))")).flatten
       end
       return []
    end

    def self.initializePrelude
      return unless FIDIUS.config['prelude']
      FIDIUS.connect_db
      h = FIDIUS::Asset::Host.find_or_create_by_ip(FIDIUS.config['prelude']['host'])
      h.name = "prelude"
      h.save
      FIDIUS.disconnect_db
    end

    addLocalAddresses
    initializePrelude

  end
end
