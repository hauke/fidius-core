require 'find'
require 'tempfile'

module Rex

  ###
  #
  # This class provides helper methods for dealing with files that are not
  # supplied by the standard ruby API.
  #
  ###
  module FileUtils

	  #
	  # This methods cleans the supplied path of directory traversal sequences
	  # It must accept path/with/..a/folder../starting/or/ending/in/two/dots
	  # but clean ../something as well as path/with/..\traversal
	  #
	  def self.clean_path(old)
		  path = old
		  while(path.index(/\/..\/|\/..\\|\\..\\|\\..\/|\A..\\|\A..\//) != nil)
			  path.gsub!(/\A..\\|\A..\//,'') #eliminate starting ..\ or ../
			  path.gsub!(/\/..\/|\/..\\/,'/') #clean linux style
			  path.gsub!(/\\..\\|\\..\//,'\\') #clean windows style
		  end
		  path
	  end

	  #
	  # This method searches the PATH environment variable for
	  # a fully qualified path to the supplied file name.
	  #
	  def self.find_full_path(file_name)
	
		  # Check for the absolute fast first
		  if (file_name[0,1] == "/" and ::File.exists?(file_name) and ::File::Stat.new(file_name))
			  return file_name
		  end
	
		  path = Rex::Compat.getenv('PATH')
		  if (path)
			  path.split(::File::PATH_SEPARATOR).each { |base|
				  begin
					  # Deal with Windows paths surrounded by quotes.  Prevents
					  # silliness like trying to look for
					  # '"C:\\framework\\nmap"\\nmap.exe' which will always fail.
					  base = $1 if base =~ /^"(.*)"$/
					  path = base + ::File::SEPARATOR + file_name
					  if (::File::Stat.new(path) and not ::File.directory?(path))
						  return path
					  end
				  rescue
				  end
			  }
		  end
		  return nil
	  end

  end # module FileUtils

  class Quickfile < ::Tempfile
	  def initialize(*args)
		  super(*args)
		  self.binmode
		  ObjectSpace.undefine_finalizer(self)	
	  end
  end

  module Find
    #
    # Identical to Find.find from Ruby, but follows symlinks to directories.
    # See http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/68671
    #
    def self.find(*paths)
      paths.collect!{|d| d.dup}
      while file = paths.shift
        catch(:prune) do
          yield file.dup.taint
          next unless File.exist? file
          begin
            if File.stat(file).directory? then
              d = Dir.open(file)
              begin
                for f in d
                  next if f == "." or f == ".."
                  if File::ALT_SEPARATOR and file =~ /^(?:[\/\\]|[A-Za-z]:[\/\\]?)$/ then
                    f = file + f
                  elsif file == "/" then
                    f = "/" + f
                  else
                    f = File.join(file, f)
                  end
                  paths.unshift f.untaint
                end
              ensure
                d.close
              end
            end
          rescue Errno::ENOENT, Errno::EACCES
          end
        end
      end
    end

    def self.prune
      throw :prune
    end

  end # module Find
end # module Rex
