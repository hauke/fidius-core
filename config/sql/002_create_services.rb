class CreateServices < ActiveRecord::Migration
  def self.up
    create_table :services do |t|
      t.string :name
      t.string :port
      t.string :proto
      t.string :info
      t.integer :host_id
    end
  end

  def self.down
    drop_table :services
  end
end
