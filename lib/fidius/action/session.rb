module FIDIUS
  module Action
    class SessionEvent
      include DRbUndumped

      #
      # Called when a session is opened.
      #
      def on_session_open(session)
        puts "got new session #{session.name.to_s}"
        begin
          FIDIUS::Action::Session.add_session_to_db session
          FIDIUS::Action::PostExploit::autorun session
        rescue
          puts "An error occurred while adding new session #{$!.inspect} #{session}"
          puts $!.backtrace
        end
      end

      #
      # Called when a session is closed.
      #
      def on_session_close(session, reason='')
        puts "Session died #{session.name.to_s} because of #{reason}"
        begin
          FIDIUS::Action::Session.remove_session_from_db session
        rescue
          puts "An error occurred while adding new session #{$!.inspect} #{session}"
          puts $!.backtrace
        end
      end

      def status
        "ok"
      end

    end # class SessionEvent

    class Session

      def self.add_session_to_db session
        lhost_addr = FIDIUS::Action::Session.get_lhost session
        lhost = FIDIUS::Asset::Interface.find_by_ip(lhost_addr)
        lhost_id = lhost ? lhost.id : nil

        rhost_addr = FIDIUS::Action::Session.get_rhost session
        piv_host = FIDIUS::Asset::Host.find_or_create_by_ip(lhost_addr)
        host = FIDIUS::Asset::Host.find_or_create_by_ip(rhost_addr)
        interface = FIDIUS::Asset::Interface.find_by_ip(rhost_addr)
        host.pivot_host_id = piv_host.id
        session_db = FIDIUS::Session.find_or_create_by_id(session.name.to_s)
        session_db.name = session.name
        session_db.exploit = session.via_exploit
        session_db.payload = session.via_payload
        exploited_service = interface.services.select{|s| s.port.to_s == session.exploit_datastore['RPORT'].to_s}
        session_db.service_id = exploited_service.first.id if exploited_service.first
        host.sessions << session_db
        session_db.save
        host.save
      end
      
      def self.remove_session_from_db session
        rhost_addr = FIDIUS::Action::Session.get_rhost session
        host = FIDIUS::Asset::Host.find_or_create_by_ip(rhost_addr)
        host.pivot_host_id = nil
        host.save
        FIDIUS::Session.delete(session.name.to_s)
      end

      def self.get_lhost session
        address = nil
        if session.respond_to? :tunnel_local and session.tunnel_local.to_s.length > 0
          return session.tunnel_local[(session.tunnel_local.rindex("-") || - 1) + 1 ..( session.tunnel_local.rindex(":") || session.tunnel_local.length + 1) - 1 ]
        else
          puts("Session with no local_host or tunnel_local")
        end
      end

      def self.get_rhost session
        if session.respond_to? :peerhost and session.peerhost.to_s.length > 0
          return session.peerhost
        elsif session.respond_to? :tunnel_peer and session.tunnel_peer.to_s.length > 0
          return session.tunnel_peer[0, session.tunnel_peer.rindex(":") || session.tunnel_peer.length ]
        elsif session.respond_to? :target_host and session.target_host.to_s.length > 0
           return session.target_host
        else
          puts("Session with no peerhost, tunnel_peer or target_host")
          return
        end
      end

      def self.register_session_handler deamon
        puts "def self.register_session_handler framework"
        @handler ||= FIDIUS::Action::SessionEvent.new
        deamon.add_session_listener @handler
      end

      def self.deregister_session_handler deamon
        deamon.remove_session_listener @handler
      end

      def self.add_existing_sessions framework
        FIDIUS::Session.delete_all
        framework.sessions.each do | key, session |
          puts "got new session #{session.name.to_s}"
          begin
            FIDIUS::Action::Session.add_session_to_db session
            FIDIUS::Action::PostExploit::autorun session
          rescue
            puts "An error occurred while adding old sessions #{$!.inspect} #{session}"
            puts $!.backtrace
          end
        end
      end

      def self.close_all_sessions
        FIDIUS::Session.delete_all
        framework = FIDIUS::Action::Msf.instance.framework
        framework.sessions.each do | key, session |
          begin
            session.kill
          rescue
            puts "An error occurred while killing sessions #{$!.inspect} #{session}"
            puts $!.backtrace
          end
        end
      end

    end # class Session
  end # module Action
end # module FIDIUS
