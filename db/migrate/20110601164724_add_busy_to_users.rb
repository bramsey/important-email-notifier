class AddBusyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :busy, :boolean
  end

  def self.down
    remove_column :users, :busy
  end
end
