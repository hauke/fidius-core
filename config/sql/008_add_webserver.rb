class AddWebserver < ActiveRecord::Migration
  def self.up
    add_column :hosts, :webserver, :string
  end
  
  def self.down
    remove_column :hosts, :webserver
  end
end
