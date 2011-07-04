require '../../../fidius.rb'

include FIDIUS::MachineLearning

@service_name = ["ssh",
                 "vnc",
                 "smtp",
                 "domain",
                 "mysql",
                 "http",
                 "netbios-ssn",
                 "microsoft-ds",
                 "ftp",
                 "ipp",
                 "afp",
                 "kerberos-sec",
                 "https",
                 "svn",
                 "aol",
                 "http-proxy",
                 "pop3",
                 "ldab",
                 "cvspserver",
                 "imap",
                 "ppp"
                ]

@services = FIDIUS::MachineLearning::known_services()

def find_service_by_name name
  @services.each do |service|
    if service["name"] == name
      return service
    end
  end
  return nil
end

def build_instance_from_csv(line)
  #host = FIDIUS::Asset::Host.find_or_create_by_ip "134.102.201.100"
  #interface = host.find_or_create_by_ip "134.102.201.100"
  values = line.split(",")
  for i in (0 .. values.length)
    if values[i].to_i == 1
      name =  @service_name[i]
      service = find_service_by_name name
      if service != nil
        puts service["name"]
        # i1.services << FIDIUS::Service.create(service)
      end
    end
  end
  puts "RATING: #{values.last.to_i}"
  # host.rating = values.last.to_i
  # return Instance.new(host, values.last.to_i)
end

training_file = ARGV[0]
iter = ARGV[1]
agent = Agent.new
instances = []

puts "------ TRAINING AGENT -------"
file = File.new(training_file, "r")
while (line = file.gets)
  instances << build_instance_from_csv(line)
  puts "-----------"
end
agent.train instances, iter
agent.save "agent.intelligence"
puts "---------- DONE -------------"
