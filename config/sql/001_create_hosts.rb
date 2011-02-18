class CreateHosts < ActiveRecord::Migration
	def self.up
    puts "create host"
		create_table :hosts do |t|
			t.integer :name
		end
	end
	
	def self.down
		drop_table :hosts
	end
end
