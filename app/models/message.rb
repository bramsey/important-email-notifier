class Message < ActiveRecord::Base
  attr_accessible :urgency, :disagree, :content

  belongs_to :relationship
  belongs_to :reverse_relationship

  validates :urgency, :presence => true
  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :relationship_id, :presence => true

  default_scope :order => 'messages.created_at DESC'
  
  def sender
    relationship.sender
  end
  
  def recipient
    relationship.recipient
  end
end
