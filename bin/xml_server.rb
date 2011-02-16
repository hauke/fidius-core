require File.join File.expand_path(File.dirname __FILE__), '..', 'lib', 'fidius'
require "xmlrpc/server"

s = XMLRPC::Server.new(8080,"127.0.0.1") 

s.add_handler("model.host.find") do |opts|
  # TODO: find :all
  # TODO: more generic, not only hosts
  res = nil
  
  if opts.size == 1
    id = opts[0].to_i
    if !FIDIUS::Asset::Host.exists?(id)
      puts "raise"
      raise XMLRPC::FaultException.new(1, "object does not exist")
    end
    res = FIDIUS::Asset::Host.find(id)
  end 
  puts "i am here and res is: #{res}"
  unless res
    puts "throw error"
    raise XMLRPC::FaultException.new(1, "object was not found")
  end
  res.to_xml
end

s.set_default_handler do |name, *args|
  raise XMLRPC::FaultException.new(-99, "Method #{name} missing" +
                                   " or wrong number of parameters!")
end
s.serve
