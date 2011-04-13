require 'yaml'

module FIDIUS

  def config
    @env ||= ENV['ENV'] || 'development'
    @cfg ||= YAML.load_file File.expand_path("../../../config/fidius.yml", __FILE__)

    begin
      require 'fidius-evasiondb'
      FIDIUS::EvasionDB.config @cfg["databases"]["evasiondb"]
    rescue
      puts "Error loading EvasionDB: #{$!.message}"
    end
    @cfg
  end
  module_function :config

end # module FIDIUS
