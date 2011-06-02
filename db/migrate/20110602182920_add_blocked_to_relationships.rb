class AddBlockedToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :blocked, :boolean
  end

  def self.down
    remove_column :relationships, :blocked
  end
end
