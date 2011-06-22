require 'rubygems' if RUBY_VERSION < '1.9'

# FIXME: `require' only when needed!

# Models
require 'active_record'

# self requirements
$LOAD_PATH.unshift File.expand_path(File.dirname __FILE__)
BASE = File.dirname __FILE__
require 'fidius/design_patterns/observer'
require 'fidius/config'

begin
  require 'fidius-evasiondb'
rescue
  puts "could not load evasiondb"
end

module FIDIUS
  # KNOWLEDGE
  autoload :Service,    'fidius/knowledge/service'
  autoload :Session,    'fidius/knowledge/session'
  autoload :Loudness,   'fidius/knowledge/loudness'
  autoload :Subnet,     'fidius/knowledge/subnet'
  autoload :Asset,      'fidius/knowledge/asset'
  autoload :Task,       'fidius/knowledge/task'
  autoload :UserDialog, 'fidius/knowledge/user_dialog' # XXX: knowledge?

  # ACTION
  autoload :Action, 'fidius/action'

  # AI
  autoload :MachineLearning,  'fidius/decision/agent/machine_learning'
  autoload :Planner,          'fidius/decision/planning/planner'
  autoload :GeneticAlgorithm, 'fidius/decision/genetic_algorithm/genetic_algorithm'

  # Server
  module Server
    autoload :RPC,    'fidius/server/xmlrpc.rb'
    autoload :Simulator,    'fidius/server/simulator.rb'
    autoload :MsfDRb, 'fidius/server/msfdrb.rb'
  end
  
  #Helper
  autoload :LabHelper, 'helper/lab_helper.rb'

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

