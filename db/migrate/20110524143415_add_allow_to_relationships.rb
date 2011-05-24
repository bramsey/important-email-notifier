class AddAllowToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :allow, :boolean
  end

  def self.down
    remove_column :relationships, :allow
  end
end
