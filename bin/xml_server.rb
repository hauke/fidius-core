require File.join File.expand_path(File.dirname __FILE__), '..', 'lib', 'fidius'
require "xmlrpc/server"

s = XMLRPC::Server.new(8080,"127.0.0.1") 

s.add_handler("auth.login") do |user,pwd|
  "asa"
end

s.add_handler("model.host.find") do |opts|
  #FIDIUS::Asset::Host.destroy_all
  erg = FIDIUS::Asset::Host.create(:name => 50)
  #erg.name = 40
  #erg.save
  puts erg.inspect
  #erg = FIDIUS::Asset::Host.first
  erg.to_xml
end

s.add_handler("michael.div") do |a,b|
  if b == 0
    raise XMLRPC::FaultException.new(1, "division by zero")
  else
    a / b 
  end
end 

s.set_default_handler do |name, *args|
  raise XMLRPC::FaultException.new(-99, "Method #{name} missing" +
                                   " or wrong number of parameters!")
end
puts "HELLO"
s.serve
