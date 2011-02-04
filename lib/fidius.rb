module FIDIUS
  
  # MISC
  require 'rubygems'
  
  $LOAD_PATH.unshift File.expand_path(File.dirname __FILE__)

  # KNOWLEDGE
  require 'fidius/knowledge/service'
  require 'fidius/knowledge/loudness'
  require 'fidius/knowledge/subnet'
  require 'fidius/knowledge/asset'

  # ACTION
  require 'fidius/action/scan'
  require 'fidius/action/scan/port_scan'
  require 'rex'

  # AI
  require 'ai4r'
  require 'algorithms'
  require 'fidius/agent/agent'
  require 'fidius/agent/predictor'

end


