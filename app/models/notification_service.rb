class NotificationService < ActiveRecord::Base
  
  belongs_to :user
  
  attr_accessible :user_id, :type, :username
  
  def notify( msg )
    # Method template for overloading.
  end
  
end
