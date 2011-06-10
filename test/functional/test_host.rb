require 'test_helper_fidius'
require 'test_helper_function'

class HostTest < FIDIUS::Test
  def test_host_bit_vector
    h = FIDIUS::Asset::Host.find_or_create_by_ip '192.168.0.2'
    inter = h.find_or_create_by_ip "192.168.0.2"
    inter.services << FIDIUS::Service.new(:name => "ssh",    :port => 22,   :proto => "tcp")
    inter.services << FIDIUS::Service.new(:name => "vnc",    :port => 5900, :proto => "tcp")
    inter.services << FIDIUS::Service.new(:name => "smtp",   :port => 25,   :proto => "tcp")
    inter.services << FIDIUS::Service.new(:name => "domain", :port => 53,   :proto => "udp")
    inter.save

    vector = inter.get_services_as_bit_vector

    expected = [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    assert_equal expected, vector
  end

  def test_neighbours
    puts "Neighbour test"
    h1 = FIDIUS::Asset::Host.find_or_create_by_ip '192.168.0.2'
    inter1 = h1.find_or_create_by_ip "192.168.0.2"
    h1.save
    inter1.save
    h2 = FIDIUS::Asset::Host.find_or_create_by_ip '192.168.0.3'
    inter2 = h2.find_or_create_by_ip "192.168.0.3"
    h2.save
    inter2.save
    h3 = FIDIUS::Asset::Host.find_or_create_by_ip '192.168.0.4'
    inter3 = h3.find_or_create_by_ip "192.168.0.4"
    h3.save
    inter3.save
    h4 = FIDIUS::Asset::Host.find_or_create_by_ip '192.168.1.2'
    inter4 = h4.find_or_create_by_ip "192.168.1.2"
    h4.save
    inter4.save
    neighbours = h1.neighbours?
    puts "NEIGH: #{neighbours}"
    assert_true(neighbours.include?(h2))
    assert_true(neighbours.include?(h3))
    assert_true(!neighbours.include?(h4))
  end
end
