class AddIndexToTokens < ActiveRecord::Migration
  def self.up
    remove_index :tokens, :value
    add_index :tokens, :value, :unique => true
  end

  def self.down
    remove_index :tokens, :value
  end
end
