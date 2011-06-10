class AddReplyToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :reply, :boolean
  end

  def self.down
    remove_column :accounts, :reply
  end
end
