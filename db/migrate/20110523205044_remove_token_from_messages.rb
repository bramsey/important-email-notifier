class RemoveTokenFromMessages < ActiveRecord::Migration
  def self.up
    remove_column :users, :token
    remove_column :messages, :token
  end

  def self.down
    add_column :users, :token, :string
    add_column :messages, :token, :string
    add_index :users, :token, :unique => true
    add_index :messages, :token, :unique => true
  end
end
