class NotificationService < ActiveRecord::Base
  
  belongs_to :user
  
  def notify( msg )
    # Method template for overloading.
  end
end
