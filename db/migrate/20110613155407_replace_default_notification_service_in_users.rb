class ReplaceDefaultNotificationServiceInUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :default_notification_service
    add_column :users, :default_notification_service_id, :integer
  end

  def self.down
    remove_column :users, :default_notification_service_id
    add_column :users, :default_notification_service, :integer
  end
end
