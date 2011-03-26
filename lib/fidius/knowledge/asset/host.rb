module FIDIUS
  module Asset
    class Host < ActiveRecord::Base
      has_many :interfaces, :class_name => "FIDIUS::Asset::Interface"
      has_many :sessions, :class_name => "FIDIUS::Session"

      #attr_accessor :services, :name, :ip

      def exploited?
        raise NotImplementedError, "not implemented yet"
      end

      def reachable?
        raise NotImplementedError, "not implemented yet"
      end

      def hostname
        raise NotImplementedError, "not implemented yet"
      end

      #def ==
      #  raise NotImplementedError, "not implemented yet"
      #end
      def find_by_ip_and_mac ip, mac
        FIDIUS::Asset::Interface.find_by_ip_and_mac_and_host_id(ip, mac, id)
      end

      def find_or_create_by_ip_and_mac ip, mac
        FIDIUS::Asset::Interface.find_or_create_by_ip_and_mac_and_host_id(ip, mac, id)
      end

      def find_by_ip ip
        FIDIUS::Asset::Interface.find_by_ip_and_host_id(ip, id)
      end

      def find_or_create_by_ip ip
        FIDIUS::Asset::Interface.find_or_create_by_ip_and_host_id(ip, id)
      end

      def self.find_or_create_by_ip_and_mac ip, mac
        interface = FIDIUS::Asset::Interface.find_or_create_by_ip_and_mac(ip, mac)
        return interface.host if interface.host
        host = create
        host.interfaces << interface
        host
      end

      def self.find_or_create_by_ip ip
        interface = FIDIUS::Asset::Interface.find_or_create_by_ip(ip)
        return interface.host if interface.host
        host = create
        host.interfaces << interface
        host
      end

    end # class Host
  end # module Asset
end # module FIDIUS

