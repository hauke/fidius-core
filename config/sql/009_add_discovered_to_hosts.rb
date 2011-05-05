class AddDiscoveredToHosts < ActiveRecord::Migration
  def self.up
    # this is only for simulation mode
    add_column :hosts, :discovered, :boolean, :default=>false, :null=>false
  end
  
  def self.down
    remove_column :hosts, :discovered
  end
end
