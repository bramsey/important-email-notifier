class Relationship < ActiveRecord::Base
  attr_accessible :recipient_id, :sender_id
  
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  has_many :messages, :dependent => :destroy
  
  validates :sender_id, :presence => true
  validates :recipient_id, :presence => true
end
