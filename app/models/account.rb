class Account < ActiveRecord::Base
  attr_accessible :username, :password
  
  belongs_to :user
  
  validates :username, :presence => true
  validates :password, :presence => true
  validates :user_id, :presence => true
  
  def self.active_accounts
    actives = []
    Account.all.each {|acct| actives << acct if acct.active}
    actives
  end
end
