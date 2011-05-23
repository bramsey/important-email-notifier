class Token < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :message
  
  validates :user_id, :presence => true
  validates :value, :presence => true, :uniqueness => true
end
