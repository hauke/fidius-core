require 'rubygems' # if RUBY_VERSION < 1.9

# Action requirements
require 'rex'
require 'tempfile'
require "fileutils"

# AI requirements
require 'ai4r'
require 'algorithms'

# Models
require 'active_record'

# self requirements
$LOAD_PATH.unshift File.expand_path(File.dirname __FILE__)
require 'fidius/misc/nmap_xml' # copied from msf/lib
require 'fidius/misc/file'     # copied from msf/lib
require 'fidius/misc/compat'   # copied from msf/lib

# TODO: make something with evironment tag
env    = ENV['ENV'] || 'development'
config = YAML.load_file File.expand_path("../../config/database.yml", __FILE__)
ActiveRecord::Base.establish_connection(config[env])

module FIDIUS
  # KNOWLEDGE
  autoload :Service,  'fidius/knowledge/service'
  autoload :Loudness, 'fidius/knowledge/loudness'
  autoload :Subnet,   'fidius/knowledge/subnet'
  autoload :Asset,    'fidius/knowledge/asset'

  # ACTION
  autoload :Action,   'fidius/action'

  # AI
  autoload :MachineLearning, 'fidius/agent/machine_learning'
  
  # XMLRPC
  module RPC
    autoload :Server, 'fidius/rpc/server'
  end
end

END {
  ActiveRecord::Base.connection.disconnect!
}
