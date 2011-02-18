require File.join File.expand_path(File.dirname __FILE__), '..', 'lib', 'fidius'
require "xmlrpc/server"

s = XMLRPC::Server.new(8080,"127.0.0.1") 
puts "START"
s.add_handler("model.host.find") do |opts|
  puts "HALLO"
  # TODO: find :all
  # TODO: more generic, not only hosts
  puts opts.inspect
  res = nil  

  

  if opts[0].to_i > 0
    # id
    opts[0] = opts[0].to_i
    res = FIDIUS::Asset::Host.find *opts
  else
    # first or last or all
    opts[0] = opts[0].to_sym
    res = FIDIUS::Asset::Host.find *opts
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
