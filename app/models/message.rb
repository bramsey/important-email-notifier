class Message < ActiveRecord::Base
  attr_accessible :urgency, :disagree, :content

  belongs_to :relationship
  belongs_to :reverse_relationship

  #validates :urgency, :presence => true
  validates :content, :length => { :maximum => 140 }
  validates :relationship_id, :presence => true

  default_scope :order => 'messages.created_at ASC'
  
  def sender
    relationship.sender
  end
  
  def recipient
    relationship.recipient
  end
  
  def disagree!
    self.disagree = true
    self.save
  end
  
  def agree!
    self.disagree = false
    self.save
  end
  
  def self.initiate(sender_email, recipient_email)
    sender = User.find_or_create_by_email( sender_email )
    recipient = User.find_by_email( recipient_email )
    msg = sender.send!( recipient )
    
    sender.reliable? ? response = Message.build_response(msg.new_token) : response = "Ignore"
  end
  
  def new_token
    #create a token attribute and assign the token to it.
    self.token = ('a'..'z').to_a.shuffle[1..6].join
    self.save
    self.token
  end
  
  def clear_token
    if self.token
      self.token = nil
      self.save
    end
  end
  
  
  private
  
    def self.build_response( token )
      root_url ||= "http://localhost:3000/"
      update_message_path ||= "messages/edit"
      link = root_url + update_message_path + "?token=" + token
    end
end
