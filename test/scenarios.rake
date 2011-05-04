# Simulator scenarios
namespace :scenario do
  # setup an scenario
  desc "setup a scenario"
  task :setup do
    ENV["ENV"] = "simulator"
    require File.join("#{$WD}","lib","helper","fidius_db_helper.rb")
    $CFG_D = File.join $WD, "config"
    @db_helper = FIDIUS::DbHelper.new $CFG_D, $WD
    @db_helper.drop_database
    @db_helper.create_database
    @db_helper.with_db do
      Dir.chdir($WD)
      ActiveRecord::Migrator.migrate("#{$CFG_D}/sql", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
    
    # require fidius
    require File.join("#{$WD}","lib","fidius.rb")
    # connect db
    FIDIUS.connect_db "simulator"
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
