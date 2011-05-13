module FIDIUS
  module Action
    module Scan
      class ArpScan < NmapScan

        # returns an array of hosts (which are up) in a given subnet
        def initialize target
          raise ArgumentError, "target not set" unless target
          @target = target
          @hosts = []
        end

        def result
          @hosts
        end

        def extract h
          if h["status"] == "up"
            #puts h["addrs"]["ipv4"]
            @hosts << h["addrs"]["ipv4"]
          end
        end

        def create_arg tmpfile
          args = ["-PR", @target]
          args.push('-oX', tmpfile)
        end

        def execute_msf session
          puts("ARP Scanning #{@target}")
          ws = session.railgun.ws2_32
          iphlp = session.railgun.iphlpapi
          found = []
          ipadd = FIDIUS::Action::Msf.instance.create_range_walker @target
          while (ip_text = ipadd.next_ip)
            puts "scan IP #{ip_text}"
            h = ws.inet_addr(ip_text)
            ip = h["return"]
            h = iphlp.SendARP(ip,0,6,6)
            if h["return"] == session.railgun.const("NO_ERROR")
              mac = h["pMacAddr"]

              # XXX: in Ruby, we would do
              #   mac.map{|m| m.ord.to_s 16 }.join ':'
              # and not
              mac_str = mac[0].ord.to_s(16) + ":" +
                  mac[1].ord.to_s(16) + ":" +
                  mac[2].ord.to_s(16) + ":" +
                  mac[3].ord.to_s(16) + ":" +
                  mac[4].ord.to_s(16) + ":" +
                  mac[5].ord.to_s(16)
              puts "IP: #{ip_text} MAC #{mac_str}"
              found << "#{ip_text}"
              #cmd_tcp_scanner(:rhost => ip_text, :ports => '20-25,80,120-140,440-450')
            end
          end
          return found
        end

      end # class ArpScan
    end # module Scan
  end # module Action
end # module FIDIUS

