class CreateSnortConfig < ActiveRecord::Migration
  def self.up
    create_table :snort_config do |t|
      t.text :bitvector
      t.integer :active_rules
      t.integer :events_count
      t.integer :events_value
      t.integer :false_positives_count
      t.integer :false_positives_value
    end
  end

  def self.down
    drop_table :snort_config
  end
end
