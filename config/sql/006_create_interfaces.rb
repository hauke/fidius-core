class CreateInterfaces < ActiveRecord::Migration
  def self.up
    create_table :interfaces do |t|
      t.string :ip
      t.string :ip_mask
      t.string :ip_ver
      t.string :mac
      t.integer :host_id
      t.integer :subnet_id
    end
    remove_column :hosts, :ip
    remove_column :hosts, :reachable_through_host_id
    remove_column :services, :host_id
    add_column :services, :interface_id, :integer
    add_column :hosts, :arch, :string
    add_column :hosts, :localhost, :boolean, :default => 0
    add_column :hosts, :attackable, :boolean, :default => 0
    add_column :hosts, :ids, :boolean, :default => 0
  end
  
  def self.down
    drop_table :interfaces
    add_column :hosts, :ip
    add_column :hosts, :reachable_through_host_id
    add_column :services, :host_id, :integer
    remove_column :services, :interface_id
    remove_column :hosts, :arch
    remove_column :hosts, :localhost
    remove_column :hosts, :attackable
    remove_column :hosts, :ids
  end
end
