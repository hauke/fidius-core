class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.string :name
      t.integer :host_id
      t.integer :service_id
      t.string :payload
      t.string :exploit
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
  
  def self.down
    drop_table :sessions
  end
end
