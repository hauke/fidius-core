attacker = FIDIUS::Asset::Host.create({:name=>"Attacker",:arch=>"i686",:localhost=>true})

attacker.add_reachable_host({:name=>"Fidius01",:os_name=>"windows",:arch=>"i686"}) do |host|
  host.add_interace(:ip=>"192.168.0.10",:ip_ver=>4,:ip_mask=>"255.255.255.0",:mac=>"64:b9:e8:c9:a2:ef") do |i|
    i.add_service(22,"ssh")
    i.add_service(111,"rpcbind")
    i.add_service(3306,"mysql")
  end
end

attacker.add_reachable_host({:name=>"Fidius02",:os_name=>"windows",:arch=>"i686"}) do |host|
  host.add_interace(:ip=>"192.168.0.14",:ip_ver=>4,:ip_mask=>"255.255.255.0",:mac=>"64:b9:e8:c9:a2:ff") do |i|
    i.add_service(22,"ssh")
    i.add_service(111,"rpcbind")
    i.add_service(3306,"mysql")
  end
  host.add_interace(:ip=>"10.30.30.5",:ip_ver=>4,:ip_mask=>"255.255.255.0",:mac=>"64:aa:e8:c9:a2:ff") do |i|
    i.add_service(22,"ssh")
    i.add_service(111,"rpcbind")
    i.add_service(3306,"mysql")
  end
  host.add_reachable_host({:name=>"Server",:arch=>"i686"}) do |host|
    host.add_interace(:ip=>"10.30.30.1",:ip_ver=>4,:ip_mask=>"255.255.255.0",:mac=>"64:fe:e8:c9:a2:ff") do |i|
      i.add_service(22,"ssh")
      i.add_service(111,"rpcbind")
      i.add_service(3306,"mysql")
    end
  end
end
