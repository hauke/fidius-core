module FIDIUS
  module Action
    # This class acts as DRb wrapper for the Metasploit framework.
    # Since Msf is a singleton object, you might get the framework with
    # something like
    #
    #     msf = FIDIUS::Action::Msf.instance.framework
    #
    # You might get an Error::ENOENT if the configuration file
    # (+config/msf.yml+) was not found.
    class Msf
      include Singleton

      # Initializes the singleton object with the configuration located
      # in +config/msf.yml+. Currently, only the +:drb_host+ and +:drb_port+
      # values are evaluated.
      #
      # The construction will fail if the configuration yaml file could
      # not be found.
      def initialize
        cfg = YAML.load_file(File.expand_path '../../../../config/msf.yml', __FILE__)
        @uri = "druby://#{cfg[:drb_host]}:#{cfg[:drb_port]}"
        begin
          DRb.current_server
        rescue DRb::DRbServerNotFound
          DRb.start_service
          ThreadGroup.new.add DRb.thread
        end
      rescue
        puts "No `config/msf.yml' found."
        raise
      end

      # Returns the Metasploit framework. Getting this object is not
      # cached. You may do that on your own.
      # 
      # @return [Msf::Simple::Framework]  The Metasploit framework.
      def framework
        daemon.framework
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
