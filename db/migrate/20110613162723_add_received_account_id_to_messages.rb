class AddReceivedAccountIdToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :received_account_id, :integer
  end

  def self.down
    remove_column :messages, :received_account_id
  end
end
