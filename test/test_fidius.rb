require 'simplecov'
  SimpleCov.start
require 'fidius'
require 'test/unit'


module FIDIUS
  class Test < Test::Unit::TestCase
    def setup
      FIDIUS.connect_db
      FIDIUS::Action::Msf.instance.start  if ENV['ENV'] == "test"
    end
    
    def teardown
      FIDIUS.disconnect_db
    end
  end
end

def vm_config
   @vms ||= YAML.load_file File.expand_path("../../config/test_vms.yml", __FILE__)
end

def vm_find_host vm
  FIDIUS::Asset::Host.find_or_create_by_ip vm[:ip]
end

def vm_find_interface vm
  h = FIDIUS::Asset::Host.find_or_create_by_ip vm[:ip]
  h.find_or_create_by_ip vm[:ip]
end

def vm_start vm
  FIDIUS::Action::Msf.instance.daemon.load_plugin "lab_api"
  msf = FIDIUS::Action::Msf.instance.framework
  msf.lab_api.lab_load vm_config[:lab_config]
  msf.lab_api.lab_start vm[:lab_name]
  sleep vm[:waittime]
end
