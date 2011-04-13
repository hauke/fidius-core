# Simulator scenarios
namespace :scenario do
  # setup an scenario
  desc "setup a scenario"
  task :setup do
    # require fidius
    require File.join("#{$WD}","lib","fidius.rb")
    # connect db
    FIDIUS.connect_db get_env
    # load scenario helper methods
    require File.join("#{$WD}","test","scenario","scenario_helper.rb")

    # try to find scenario file and load it
    sid = ENV["ID"]
    raise "please provide scenario id. Ex: rake scenario:setup ID=001" unless sid
    sfile =  File.join("#{$WD}","test","scenario","#{sid}_scenario.rb")
    raise "#{sfile} does not exists" unless File.exists?(sfile)
    require sfile
  end
end
