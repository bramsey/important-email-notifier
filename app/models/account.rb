class Account < ActiveRecord::Base
  attr_accessible :username, :password, :active, :token, :secret
  
  after_create :set_default_notification_service
  
  belongs_to :user
  belongs_to :notification_service
  
  validates :username, :presence => true
  validates :user_id, :presence => true
  
  def self.active_accounts
    actives = []
    Account.all.each {|acct| actives << acct if acct.active}
    actives
  end
  
  private
    
    def set_default_notification_service
      update_attribute(:notification_service_id, user.default_notification_service)
    end
end
