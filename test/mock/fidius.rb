module FIDIUS
  module Server
    class MsfDRb

      def create_framework
        FIDIUS::MsfMock::Framework.new
      end

      def run_exploit(exploit, opts)
        session = FIDIUS::MsfMock::SessionMock.new "1", exploit
        @framework.sessions << session
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
      
        def self.filename filename
          @@filename = filename
        end

        def run_nmap fd
          args = create_arg fd.path
          FileUtils.cp @@filename, fd.path
        end

      end # class NmapScan
    end # module Scan
  end # module Action
end # module FIDIUS
