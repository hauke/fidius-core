class AddServiceState < ActiveRecord::Migration
  def self.up
    # this is only for simulation mode
    add_column :services, :state, :string
  end
  
  def self.down
    remove_column :services, :state
  end
end
