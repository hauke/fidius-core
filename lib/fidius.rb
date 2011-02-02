module FIDIUS
  # MISC
  require 'rubygems'

  # KNOWLEDGE
  require File.join(File.dirname(__FILE__),'fidius' ,'knowledge', 'service')
  require File.join(File.dirname(__FILE__),'fidius' , 'knowledge', 'loudness')
  require File.join(File.dirname(__FILE__),'fidius' , 'knowledge', 'subnet')
  require File.join(File.dirname(__FILE__),'fidius' , 'knowledge', 'asset')

  # AI
  require 'ai4r'
  require 'algorithms'  
  require File.join(File.dirname(__FILE__),'fidius' , 'agent', 'agent')
  require File.join(File.dirname(__FILE__),'fidius' , 'agent', 'predictor')

  # ACTION
  require File.join(File.dirname(__FILE__),'fidius' , 'action', 'scan')
  
end
