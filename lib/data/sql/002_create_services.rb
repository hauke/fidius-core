class CreateServices < ActiveRecord::Migration
	def self.up
		create_table :services do |t|
			t.string :name
      t.integer :port
      t.string :proto
      t.integer :host_id
		end
	end
	
	def self.down
		drop_table :services
	end
end
