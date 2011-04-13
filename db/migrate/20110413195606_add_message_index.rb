class AddMessageIndex < ActiveRecord::Migration
  def self.up
    add_index :messages, :relationship_id
  end

  def self.down
    remove_index :messages, :relationship_id
  end
end
