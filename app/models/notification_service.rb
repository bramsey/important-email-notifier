class NotificationService < ActiveRecord::Base
  
  belongs_to :user
  
  def notify
    # Method template for overloading.
  end
end
