class AddRelationshipIndex < ActiveRecord::Migration
  def self.up
    add_index :relationships, :sender_id
    add_index :relationships, :recipient_id
    add_index :relationships, [:sender_id, :recipient_id], :unique => true
  end

  def self.down
    remove_index :relationships, :sender_id
    remove_index :relationships, :recipient_id
    remove_index :relationships, [:sender_id, :recipient_id]
  end
end
