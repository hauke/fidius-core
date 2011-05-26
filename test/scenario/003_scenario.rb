attacker = FIDIUS::Asset::Host.create({:name=>"Attacker",:arch=>"i686",:localhost=>true,:discovered=>true})
attacker.add_interace(:ip=>"134.102.113.22",:ip_ver=>4,:ip_mask=>"255.255.255.0") do |i|
  i.add_service(22,"ssh")
end

attacker.add_reachable_host({:name=>"Workstation",:os_name=>"WindowsXP",:arch=>"i686"}) do |host|
  host.add_interace(:ip=>"192.168.22.4",:ip_ver=>4,:ip_mask=>"255.255.255.0") do |i|
    i.add_service(135,"msrpc")
    i.add_service(139,"netbios-ssn")
    i.add_service(445,"microsoft-ds")
  end

  host.add_reachable_host({:name=>"Webserver",:os_name=>"Ubuntu",:arch=>"i686"}) do |host|
    host.add_interace(:ip=>"55.12.33.105",:ip_ver=>4,:ip_mask=>"255.255.255.0") do |i|
      i.add_service(22,"ssh")
      i.add_service(111,"rpcbind")
      i.add_service(3306,"mysql")
    end
    host.add_interace(:ip=>"192.168.22.105",:ip_ver=>4,:ip_mask=>"255.255.255.0") do |i|
      i.add_service(22,"ssh")
      i.add_service(111,"rpcbind")
      i.add_service(3306,"mysql")
    end


    host.add_reachable_host({:name=>"Workstation",:os_name=>"WindowsXP",:arch=>"i686"}) do |host|
      host.add_interace(:ip=>"192.168.22.3",:ip_ver=>4,:ip_mask=>"255.255.255.0") do |i|
        i.add_service(135,"msrpc")
        i.add_service(139,"netbios-ssn")
        i.add_service(445,"microsoft-ds")
      end
    end

    host.add_reachable_host({:name=>"Workstation",:os_name=>"WindowsXP",:arch=>"i686"}) do |host|
      host.add_interace(:ip=>"192.168.22.2",:ip_ver=>4,:ip_mask=>"255.255.255.0") do |i|
        i.add_service(135,"msrpc")
        i.add_service(139,"netbios-ssn")
        i.add_service(445,"microsoft-ds")
      end

      host.add_interace(:ip=>"10.10.20.5",:ip_ver=>4,:ip_mask=>"255.255.255.0") do |i|
      end

      host.add_reachable_host({:name=>"Chef",:os_name=>"WindowsXP",:arch=>"i686"}) do |host|
        host.add_interace(:ip=>"10.10.20.100",:ip_ver=>4,:ip_mask=>"255.255.255.0") do |i|
          i.add_service(135,"msrpc")
          i.add_service(139,"netbios-ssn")
          i.add_service(445,"microsoft-ds")
        end
      end

      
    end

  end
end



