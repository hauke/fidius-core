require File.join File.expand_path(File.dirname __FILE__), '..', 'lib', 'fidius'
require "xmlrpc/server"
require "fidius/misc/json_symbol_addon.rb"

s = XMLRPC::Server.new(8080,"127.0.0.1") 
puts "START"

s.add_handler("model.find") do |opts|
  raise XMLRPC::FaultException.new(1, "model.find expects at least 2 parameters(modelname, opts)") if opts.size < 2
  model_name = opts.shift
  opts = ActiveSupport::JSON.decode(opts[0])
  res = nil  
  model = nil
  
  begin
    # search model in FIDIUS namespace
    model = Kernel.const_get("FIDIUS").const_get(model_name)
  rescue 
  end
  begin
    # search model in FIDIUS::Asset namespace
    model = Kernel.const_get("FIDIUS").const_get("Asset").const_get(model_name)
  rescue 
  end
  raise XMLRPC::FaultException.new(2, "Class #{model_name} was not found") unless model

  res = model.find *opts
  unless res
    raise XMLRPC::FaultException.new(3, "object was not found")
  end
  res.to_xml
end

s.set_default_handler do |name, *args|
  raise XMLRPC::FaultException.new(-99, "Method #{name} missing" +
                                   " or wrong number of parameters!")
end
s.serve
