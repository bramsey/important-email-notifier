class AddTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :token, :string
    add_index :users, :token, :unique => true
  end

  def self.down
    remove_column :users, :token
    remove_index :users, :token
  end
end
