class CreateHosts < ActiveRecord::Migration
	def self.up
		create_table :hosts do |t|
			t.string :name
      t.string :ip
		end
	end
	
	def self.down
		drop_table :hosts
	end
end