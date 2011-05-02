class Account < ActiveRecord::Base
  attr_accessible :username, :password
  
  belongs_to :user
  
  validates :username, :presence => true
  validates :password, :presence => true
  validates :user_id, :presence => true
  
end
