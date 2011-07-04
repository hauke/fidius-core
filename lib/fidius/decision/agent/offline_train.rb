require '../../../fidius.rb'
require '../../../helper/fidius_db_helper'

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


def prepare_test_db
  wd = Dir.pwd
  cfg_d = File.join wd, "../../../../config"
  ENV['ENV'] = "test"
#  #ActiveRecord::Migration.verbose = false
  db_helper = FIDIUS::DbHelper.new cfg_d, wd
  db_helper.drop_database  rescue nil
  db_helper.create_database
  db_helper.with_db {
    Dir.chdir(wd)
    ActiveRecord::Migrator.migrate("#{cfg_d}/sql", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  }
end

def find_service_by_name name
  @services.each do |service|
    if service["name"] == name
      return service
    end
  end
  return nil
end

def build_instance_from_csv(line, host)
  host = FIDIUS::Asset::Host.find_or_create_by_ip host
  interface = host.find_or_create_by_ip host
  values = line.split(",")
  for i in (0 .. values.length)
    if values[i].to_i == 1
      name =  @service_name[i]
      service = find_service_by_name name
      if service != nil
        puts service["name"]
        interface.services << FIDIUS::Service.create(service)
      end
    end
  end
  puts "RATING: #{values.last.to_i}"
  host.rating = values.last.to_i
  host
  return Instance.new(host, values.last.to_i)
end

training_file = ARGV[0]
iter = ARGV[1].to_i
agent = Agent.new
instances = []

prepare_test_db
FIDIUS.connect_db

puts "------ TRAINING AGENT -------"
file = File.new(training_file, "r")
count = 0
while (line = file.gets)
  instances << build_instance_from_csv(line, "134.102.201.#{count}")
  puts "-----------"
  count = count +1
end
agent.train instances, iter
p "Best Host: #{(agent.decision [instances[0].host, instances[9].host]).to_s}"
p "NEXT: #{(agent.next).to_s}"
puts "---------- DONE -------------"
