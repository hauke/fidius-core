require "xmlrpc/server"

module XMLRPC
  class Server
  def initialize(port=8080, host="127.0.0.1", maxConnections=4, stdlog=$stdout, audit=true, debug=true, *a)
    super(*a)
    @server = self
  end

  def serve
    signals = %w[INT TERM HUP] & Signal.list.keys
    signals.each { |signal| trap(signal) {  } }
  end

  def shutdown
  end

  def start    
    nil
  end

  def mount(dir, servlet, *options)
    nil
  end

  def call(methodname, *args)
    handle(methodname, *args)
  end
  end # class Server
end #module XMLRPC
