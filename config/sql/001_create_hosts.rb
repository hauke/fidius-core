class CreateHosts < ActiveRecord::Migration
  def self.up
    create_table :hosts do |t|
      t.string :name
      t.string :ip
      t.integer :rating
      t.boolean :exploited, :default => 0
      t.string :os_name
      t.string :os_sp
      t.integer :pivot_host_id # TODO: this is obsolet??
      t.integer :reachable_through_host_id
    end
  end

  def self.down
    drop_table :hosts
  end
end
