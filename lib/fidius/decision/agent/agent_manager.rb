module FIDIUS
  module MachineLearning
    class AgendManager
      include Singleton

      def initialize
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
        reset
      end

      def fill_with_database
        instances = []
        FIDIUS::Asset::Host.all.each do |host|
          instances << host unless host.localhost or host.ids
        end
        @agent.decision instances
      end

      def agent
        @agent
      end

      def reset
        training_file = "#{File.dirname(File.absolute_path __FILE__)}/nmap.dat" #TODO: add config option for this
        iter = 10 #TODO: add config option for this
        @agent = FIDIUS::MachineLearning::Agent.new
        instances = []

        file = File.new(training_file, "r")
        count = 0
        while (line = file.gets)
          instances << build_instance_from_csv(line, "134.102.201.#{count}")
          count = count + 1
        end

        @agent.train instances, iter
        fill_with_database
      end

      def find_service_by_name name
        @services.each do |service|
          if service["name"] == name
            return service
          end
        end
        return nil
      end

      def build_instance_from_csv(line, ip)
        # Build host + Interface
        host = FIDIUS::Asset::Host.new
        interface = FIDIUS::Asset::Interface.new({:ip => ip, :host_id => host.id})
        host.interfaces << interface

        # split csv line
        values = line.split(",")
        for i in (0 .. values.length)
          # for each running service
          if values[i].to_i == 1
            # find by port number
            name =  @service_name[i]
            service = find_service_by_name name

            if service != nil
              interface.services << FIDIUS::Service.new(service)
            end
          end
        end
        host.rating = values.last.to_i
        host
        return Instance.new(host, values.last.to_i)
      end

    end
  end
end

