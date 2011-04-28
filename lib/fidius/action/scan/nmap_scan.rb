module FIDIUS
  module Action
    module Scan
      class NmapScan

        include FIDIUS::Action::Scan

        def execute
          fd = Tempfile.new('xmlnmap')
          fd.binmode
          run_nmap fd
          data = ""
          ::File.open(fd.path, 'rb') do |f|
            data = f.read(f.stat.size)
          end
          arguments = {:filename => fd.path}.merge(:data => data)
          # Use a stream parser instead of a tree parser so we can deal with
          # huge results files without running out of memory.
          parser = Rex::Parser::NmapXMLStreamParser.new
          parser.on_found_host = Proc.new do |h|
            extract h
          end
          fd.close(true)
          REXML::Document.parse_stream(data, parser)
          return result
        end

        def result
          raise "Implement this method in subclass"
        end

        def extract h
          raise "Implement this method in subclass"
        end

        def run_nmap fd
          nmap = Rex::FileUtils.find_full_path("nmap") || Rex::FileUtils.find_full_path("nmap.exe")

          if (not nmap)
            puts("The nmap executable could not be found")
            return
          end

          args = create_arg fd.path
          raise "Nmap arp-scan failed" unless (system("#{nmap} #{args.join(' ')}"))
        end

        def create_arg tmpfile
          raise "Implement this method in subclass"
        end

      end # class NmapScan
    end # module Scan
  end # module Action
end # module FIDIUS

