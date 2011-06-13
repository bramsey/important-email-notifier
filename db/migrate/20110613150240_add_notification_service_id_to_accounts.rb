class AddNotificationServiceIdToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :notification_service_id, :integer
  end

  def self.down
    remove_column :accounts, :notification_service_id
  end
end
