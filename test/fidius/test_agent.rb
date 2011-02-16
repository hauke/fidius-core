require File.join(File.dirname(__FILE__), '..', '..','lib', 'fidius')
include FIDIUS::MachineLearning

# Training set of 2 hosts
h1 = FIDIUS::Asset::Host.new("KEEEEEKS", "")
h1.services = []
h1.services << FIDIUS::Service.new("ssh", 22, "tcp")
h1.services << FIDIUS::Service.new("vnc", 5900, "tcp")
h1.services << FIDIUS::Service.new("smtp", 25, "tcp")
h1.services << FIDIUS::Service.new("domain", 53, "udp")
inst = Instance.new(h1, 2)

h2 = FIDIUS::Asset::Host.new("KEEEEEKS2", "")
h2.services = []
h2.services << FIDIUS::Service.new("ssh", 22, "tcp")
h2.services << FIDIUS::Service.new("vnc", 5900, "tcp")
h2.services << FIDIUS::Service.new("smtp", 25, "tcp")
h2.services << FIDIUS::Service.new("domain", 53, "udp")
inst2 = Instance.new(h2, 3)

# Test set (without services)
h3 = FIDIUS::Asset::Host.new("101", "134.102.201.101")
h4 = FIDIUS::Asset::Host.new("102", "134.102.201.102")
h5 = FIDIUS::Asset::Host.new("103", "134.102.201.103")

# Train agent
agent = Agent.new
agent.train([inst, inst2], 100)

# Choose next
dec = agent.decision([h3,h4,h5])
puts "hack #{dec.name} with ip #{dec.ip} next"
