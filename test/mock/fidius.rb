module FIDIUS
  module Server
    class MsfDRb

      def create_framework
        FIDIUS::MsfMock::Framework.new
      end

      def run_exploit(exploit, opts)
        session = FIDIUS::MsfMock::SessionMock.new "1", exploit
        @framework.sessions.merge({"1" => session})
        @framework.events.subscriber.on_session_open(session)
      end

    end # class MsfDRbD
  end # module Server

  module Action
    class Msf

      # Returns the Metasploit framework DRb wrapper. Useful for debugging.
      #
      # @return [FIDIUS::MsfDRbD]  The DRb wrapper.
      def daemon
        @msf_daemon ||= FIDIUS::Server::MsfDRb.new
      end

private

      def start_drb
        # Nothing to do
      end

    end # class Msf

    module Scan
      class NmapScan

        @@filename_ping = nil
        @@filename_port = nil
      
        def self.filename_port filename
          @@filename_port = filename
        end

        def self.filename_ping filename
          @@filename_ping = filename
        end

        def self.filename_arp filename
          @@filename_arp = filename
        end

        def run_nmap fd
          args = create_arg(fd.path).join(' ')
          if args.include?("-sP")
            ip = args.scan(/-sP ([0-9\.\/]*) -oX/).flatten[0].gsub("\/", "-")
            filename = @@filename_ping
            filename ||= File.join(File.expand_path(File.dirname(__FILE__)), '..', 'functional', 'data', "nmap-ping-scan-#{ip}.xml")
          end
          if args.include?("-sV")
            ip = args.scan(/-sV ([0-9\.]*) -oX/).flatten[0]
            filename = @@filename_port
            filename ||= File.join(File.expand_path(File.dirname(__FILE__)), '..', 'functional', 'data', "nmap-port-scan-#{ip}.xml")
          end
          FileUtils.cp filename, fd.path
        end

      end # class NmapScan
    end # module Scan
  end # module Action
end # module FIDIUS
