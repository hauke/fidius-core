def vm_find_host vm
  FIDIUS::Asset::Host.find_or_create_by_ip vm[:ip]
end

def vm_find_interface vm
  h = FIDIUS::Asset::Host.find_or_create_by_ip vm[:ip]
  h.find_or_create_by_ip vm[:ip]
end

def vm_revert vm, snapshot=vm[:default_snapshot]
  msf = FIDIUS::Action::Msf.instance.framework
  if snapshot
    msf.lab_api.lab_revert vm[:lab_name], snapshot
    return 0
  else
    return -1
  end
end

def vm_start vm
    if vm
      msf = FIDIUS::Action::Msf.instance.framework
      msf.lab_api.lab_start vm[:lab_name]
      sleep vm[:waittime]
      return 0
    else
      return -1
    end
end

def run_with_vm vm_key_list, &block
  FIDIUS::Action::Msf.instance.daemon.load_plugin "lab_api"
  msf = FIDIUS::Action::Msf.instance.framework
  msf.lab_api.lab_load FIDIUS.config[:tests][:lab_config]  if FIDIUS.config[:tests]
  vm_key_list.each do |vm_key|
    vm = FIDIUS.config[:tests][vm_key]  if FIDIUS.config[:tests]
    if vm
      vm_revert vm
      vm_start vm
      yield
    else
      puts "VM not defined"
    end
  end
end
