class AddHostInfo < ActiveRecord::Migration
  def self.up
    # this is only for simulation mode
    add_column :hosts, :os_info, :string
    add_column :hosts, :lang, :string
  end
  
  def self.down
    remove_column :hosts, :os_info
    remove_column :hosts, :lang
  end
end
