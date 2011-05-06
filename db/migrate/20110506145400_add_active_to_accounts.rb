class AddActiveToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :active, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :active
  end
end
