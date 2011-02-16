require "xmlrpc/client"

# copied from lib/msf/core/rpc/client.rb
# Changed to TCPSocket to get rid of rex-library
class Client < ::XMLRPC::Client

	attr_accessor :sock, :token

	# Use a TCP socket to do RPC
	def initialize(info={})
		@buff = ""
    # TODO: what about SSL ?
    self.sock = TCPSocket.new(info[:host],info[:port])
	end

	# This override hooks into the RPCXML library
	def do_rpc(request,async)

		self.sock.puts(request + "\x00")
		
		begin
			while(not @buff.index("\x00"))
				if ::IO.select([self.sock], nil, nil, 30)
					resp = self.sock.sysread(32768)
					@buff << resp if resp
				end
			end
		rescue ::Exception => e
			self.sock.close rescue nil
			raise EOFError, "XMLRPC connection closed"
		end

		mesg,left = @buff.split("\x00", 2)
		@buff = left.to_s
		mesg
	end

	def login(user,pass)
		res = self.call("auth.login", user, pass)
		if(not (res and res['result'] == "success"))
			raise RuntimeError, "authentication failed"
		end
		self.token = res['token']
		true
	end

	# Prepend the authentication token as the first parameter
	# of every call except auth.login. Requires the
	def call(meth, *args)
		#if(meth != "auth.login")
		#	if(not self.token)
		#		raise RuntimeError, "client not authenticated"
		#	end
		#	args.unshift(self.token)
		#end

		super(meth, *args)
	end

	def close
		self.sock.close
	end

end


host = "127.0.0.1"
port = "8080"
ssl = false
user = "msf"
pass = "hallo"

#rpc = Client.new(
#	:host => host,
#	:port => port,
#	:ssl  => ssl
#)
rpc = XMLRPC::Client.new(host,"/",port)

#res = rpc.login(user, pass)

#puts "#{res.inspect}"

puts rpc.call("model.host.find",1)

