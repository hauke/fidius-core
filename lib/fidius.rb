module FIDIUS
  
  # MISC
  require 'rubygems'

  $LOAD_PATH.unshift File.expand_path(File.dirname __FILE__)

  require 'fidius/misc/nmap_xml' # copied from msf/lib
  require 'fidius/misc/file'     # copied from msf/lib

  # KNOWLEDGE
  require 'fidius/knowledge/service'
  require 'fidius/knowledge/loudness'
  require 'fidius/knowledge/subnet'
  require 'fidius/knowledge/asset'

  # ACTION
  require 'fidius/action/scan'
  require 'fidius/action/scan/port_scan'
  require 'rex'
  require 'tempfile'
  require "fileutils"

  # AI
  require 'ai4r'
  require 'algorithms'
  require 'fidius/agent/agent'
  require 'fidius/agent/predictor'
  
end


