module FIDIUS
  
  # MISC
  require 'rubygems'
  require 'misc/nmap_xml' # copied from msf/lib
  require 'misc/file'     # copied from msf/lib
  
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
  require 'tempfile'
  require "fileutils"

  # AI
  require 'ai4r'
  require 'algorithms'
  require 'fidius/agent/agent'
  require 'fidius/agent/predictor'
  
end


