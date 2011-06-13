class AddDefaultNotificationServiceToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_notification_service, :integer
  end

  def self.down
    remove_column :users, :default_notification_service
  end
end
