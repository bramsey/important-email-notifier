class NotificationService < ActiveRecord::Base
  
  belongs_to :user
  has_many :accounts
  
  def notify
    # Method template for overloading.
  end
end
