class CreateUserDialogs < ActiveRecord::Migration
  def self.up
    create_table :user_dialogs do |t|
      t.string :title
      t.integer :host_id
      t.string :message
      t.integer :dialog_type
      t.timestamps
    end
  end

  def self.down
    drop_table :user_dialogs
  end
end
