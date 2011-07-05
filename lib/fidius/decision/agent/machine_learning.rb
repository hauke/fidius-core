require 'algorithms'
require 'ai4r'

module FIDIUS
  include FIDIUS::Action::Scan
  
  module MachineLearning
    autoload :AgendManager,	'fidius/decision/agent/agent_manager'

    include Containers
    include Ai4r

    NODES_PER_LAYER = 10
    OUT = 1
    
    self.autoload :Agent,     'fidius/decision/agent/agent'
    self.autoload :Predictor, 'fidius/decision/agent/predictor'

    def self.agent
      @@AGENT ||= Agent.new()
    end

    def self.known_services
      @@services ||= YAML.load_file File.expand_path("../../../../../config/services.yml", __FILE__)
    end

    # TODO delete (host.value)
    class Instance
      attr_accessor :host, :value

      def initialize host, value
        @host = host
        @value = [value]
      end
    end

    def str2example lin
      example = []
      str = line.split(",")
      str.each do |s|
        example << s.to_i
      end
      return example
    end
    
  end # module MachineLearning
end # module FIDIUS
