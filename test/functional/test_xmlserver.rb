require 'test_helper_fidius'
require 'test_helper_function'
require 'active_support/testing/assertions'

class XMLServerTest < FIDIUS::Test
  include ActiveSupport::Testing::Assertions

  def setup
    super
    FIDIUS::Asset::Host.delete_all
    FIDIUS::Service.delete_all
    FIDIUS::Asset::Interface.delete_all
    h = FIDIUS::Asset::Host.find_or_create_by_ip "192.168.56.1"
    h.localhost = true
    h.save
  end

  def test_scan_host_xmlserver
    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.101"
    assert !h
    xmlrpc = FIDIUS::Server::RPC.new
    result = xmlrpc.call("action.scan","192.168.56.0/24")
    assert_equal "<?xml version=\"1.0\" ?><methodResponse><params><param><value><string>ok</string></value></param></params></methodResponse>\n", result

    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.101"
    assert !h
    sleep 10
    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.101"
    assert h
    assert_equal "Windows", h.os_name
    assert_equal h.interfaces[0].services.size, 7
    service = FIDIUS::Service.find_by_port_and_proto_and_interface_id(135, "tcp", h.interfaces[0].id )
    assert service
    assert_equal "Microsoft Windows RPC", service.info
    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.2"
    assert !h
    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.102"
    assert h
    assert_equal "Windows", h.os_name
    assert_equal h.interfaces[0].services.size, 4
    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.103"
    assert h
    assert_equal "Windows", h.os_name
    assert_equal h.interfaces[0].services.size, 7
  end

  def test_ask_agent
    xmlrpc = FIDIUS::Server::RPC.new
    result = xmlrpc.call("decision.next_host")
    assert_equal "<?xml version=\"1.0\" ?><methodResponse><params><param><value><i4>-1</i4></value></param></params></methodResponse>\n", result

    result = xmlrpc.call("action.scan","192.168.56.0/24")
    assert_equal "<?xml version=\"1.0\" ?><methodResponse><params><param><value><string>ok</string></value></param></params></methodResponse>\n", result

    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.101"
    assert !h
    sleep 4
    h = FIDIUS::Asset::Host.find_by_ip "192.168.56.101"
    assert h
    result = xmlrpc.call("decision.next_host")
    interface = result.scan(/<i4>(.*)<\/i4>/).flatten[0]
    assert_equal "192.168.56.101", FIDIUS::Asset::Interface.find_by_id(interface).ip
  end
end
