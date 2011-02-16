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

# TODO: make something with eviroment tag
conn = YAML::load(File.open(File.expand_path('../../lib/data/database.yml', __FILE__)))
ActiveRecord::Base.establish_connection(conn["development"])


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
end


