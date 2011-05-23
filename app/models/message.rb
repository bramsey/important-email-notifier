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
    self.update_attribute(:disagree, true)
  end
  
  def agree!
    self.update_attribute(:disagree, false)
  end
  
  def self.initiate(sender_email, recipient_email)
    sender = User.find_or_create_by_email( sender_email )
    recipient = User.find_or_create_by_email( recipient_email )
    msg = sender.send!( recipient )
    
    sender.reliable? ? response = Message.build_response(msg.new_token( sender)) : response = "Ignore"
  end
  
  def new_token( user )
    #create a token attribute and assign the token to it.
    self.update_attribute( :token, ('a'..'z').to_a.shuffle[1..6].join )
    user.set_token( self.token )
  end
  
  def clear_token
    if self.token
      user = User.find_by_token( token )
      user.clear_token if user
      self.update_attribute(:token, nil)
    end
  end
  
  
  private
  
    def self.build_response( token )
      root_url ||= "http://localhost:3000/"
      update_message_path ||= "prioritize"
      link = root_url + update_message_path + "?token=" + token
    end
end
