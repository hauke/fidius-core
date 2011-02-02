require File.join(File.dirname(__FILE__), '..', '..','lib', 'fidius')
include FIDIUS::MachineLearning

h1 = FIDIUS::Asset::Host.new("KEEEEEKS")
h1.services = []
h1.services << FIDIUS::Service.new("ssh", 22, "tcp")
h1.services << FIDIUS::Service.new("vnc", 5900, "tcp")
h1.services << FIDIUS::Service.new("smtp", 25, "tcp")
h1.services << FIDIUS::Service.new("domain", 53, "udp")
inst = Instance.new(h1, 2)

h2 = FIDIUS::Asset::Host.new("KEEEEEKS2")
h2.services = []
h2.services << FIDIUS::Service.new("ssh", 22, "tcp")
h2.services << FIDIUS::Service.new("vnc", 5900, "tcp")
h2.services << FIDIUS::Service.new("smtp", 25, "tcp")
h2.services << FIDIUS::Service.new("domain", 53, "udp")
inst2 = Instance.new(h2, 3)

agent = Agent.new
agent.train([inst, inst2], 100)
