class Relationship < ActiveRecord::Base
  attr_accessible :recipient_id, :sender_id
  
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  has_many :messages, :dependent => :destroy
  
  validates :sender_id, :presence => true
  validates :recipient_id, :presence => true
  
  def reliable?
    good_count = 0
    bad_count = 0
    
    messages.each do |msg|
      if msg.disagree?
        bad_count += 1 
        good_count = 0
      else
        good_count += 1
      end
      if good_count == 10
        bad_count = 0
      elsif bad_count == 3
        return false
      end
    end
    return true
  end
  
  def reliability
    return "Insufficiently tested" if messages.count < 10 
    reliable? ? "Reliable" : "Unreliable"
  end
    
end
