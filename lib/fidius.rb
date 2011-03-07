require 'rubygems' # if RUBY_VERSION < 1.9

# Action requirements
require 'tempfile'
require 'fileutils'
require 'yaml'
require 'drb'
require 'singleton'

# AI requirements
require 'ai4r'
require 'algorithms'

# Models
require 'active_record'

# self requirements
# FIXME: `require' only when needed!
$LOAD_PATH.unshift File.expand_path(File.dirname __FILE__)
require 'fidius/misc/ip_helper' # copied from old candc
require 'fidius/misc/nmap_xml' # copied from msf/lib
require 'fidius/misc/file'     # copied from msf/lib
require 'fidius/misc/compat'   # copied from msf/lib
require 'fidius/design_patterns/observer'

require 'fidius/config'

module FIDIUS
  # KNOWLEDGE
  autoload :Service,  'fidius/knowledge/service'
  autoload :Loudness, 'fidius/knowledge/loudness'
  autoload :Subnet,   'fidius/knowledge/subnet'
  autoload :Asset,    'fidius/knowledge/asset'
  autoload :Task,    'fidius/knowledge/task'
  autoload :UserDialog,    'fidius/knowledge/user_dialog'

  # ACTION
  autoload :Action,   'fidius/action'

  # AI
  autoload :MachineLearning, 'fidius/decision/agent/machine_learning'
  autoload :Planner,         'fidius/decision/planning/planner'
  
  # XMLRPC
  module RPC
    autoload :Server, 'fidius/rpc/server'
  end
  
  def connect_db env=nil
    databases = config['databases']
    env ||= @env
    ActiveRecord::Base.establish_connection databases[env]
  end
  module_function :connect_db
  
  def disconnect_db
    ActiveRecord::Base.connection.disconnect!
  end
  module_function :disconnect_db
end

