class AddTokenToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :token, :string
    add_index :messages, :token, :unique => true
  end

  def self.down
    remove_column :messages, :token
    remove_index :messages, :token
  end
end
