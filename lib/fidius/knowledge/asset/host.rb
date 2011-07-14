module FIDIUS
  module Asset


    class Host < ActiveRecord::Base
      has_many :interfaces, :class_name => "FIDIUS::Asset::Interface"
      has_many :services, :through => :interfaces
      has_many :sessions, :class_name => "FIDIUS::Session"

      @@IPv6_DELIM = ':'
      @@IPv4_DELIM = '.'
      #attr_accessor :services, :name, :ip

      def subnets
        subnets = []
        self.interfaces.each do |interface|
          # Parse ip adresses
          if interface.ip != nil
            # puts "IP: #{interface.ip}"

            ip_comp = interface.ip.split(@@IPv4_DELIM)

            if ip_comp.length == 1 # no IPv4_DELIM found
              # ipv6
              ip_comp = interface.ip.split(@@IPv6_DELIM)
              4.times do # delete host identifier
                ip_comp.pop
              end

              # build ip range
              str_ip = String.new
              ip_comp.each do |i|
                str_ip << i << ":"
              end
              str_ip << ":/64"
              subnets << Subnet.new(str_ip)
            else
              # ipv4
              ip_comp.pop # delete host identifier

              # build ip range
              str_ip = String.new
              ip_comp.each do |i|
                str_ip << i << "."
              end
              str_ip << "0/24"
              subnets << Subnet.new(str_ip)
            end
          end
        end
        subnets
      end

      def exploited?
        !sessions.empty?
      end

      def reachable?
        raise NotImplementedError, "not implemented yet"
      end

      def neighbours?
        # All hosts in subnets are neighbours
        neighbours = []
        nets = self.subnets()
        hosts = Host.all()
        hosts.each do |host|
          if host.id != self.id
            hnets = host.subnets()
            nets.each do |net|
              if hnets.include?(net)
                neighbours << host
                break
              end
            end
          end
        end
        return neighbours
      end

      def name_or_ip
        return name if name
        return interfaces.first.ip if interfaces.first
      end

      #def ==
      #  raise NotImplementedError, "not implemented yet"
      #end

      def find_exploits_for_host
        ports = []
        self.interfaces.each do |i|
          ports.concat(i.services.map { |s| s.port }).uniq
        end
        FIDIUS::EvasionDB::Knowledge.find_exploits_for_services(ports)
      end

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
        interface = FIDIUS::Asset::Interface.find_or_create_by_ip_and_host_id(ip, id)
        self.interfaces << interface
        interface
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

      def self.find_by_ip ip
        interface = FIDIUS::Asset::Interface.find_by_ip(ip)
        return nil unless interface
        return interface.host
      end

    end # class Host
  end # module Asset
end # module FIDIUS

