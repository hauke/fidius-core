require 'yaml'

module FIDIUS

  def config
    @env ||= ENV['ENV'] || 'development'
    @cfg ||= YAML.load_file File.expand_path("../../../config/fidius.yml", __FILE__)

    begin
      FIDIUS::EvasionDB.config @cfg["databases"]["evasiondb"]
    rescue
      puts "Error in config EvasionDB: #{$!.message}"
    end
    @cfg
  end
  module_function :config

end # module FIDIUS
