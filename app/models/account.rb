class Account < ActiveRecord::Base
  attr_accessible :username, :password, :active, :token, :secret
  
  belongs_to :user
  has_one :notification_service
  
  validates :username, :presence => true
  validates :user_id, :presence => true
  
  def self.active_accounts
    actives = []
    Account.all.each {|acct| actives << acct if acct.active}
    actives
  end
end
