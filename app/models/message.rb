class Message < ActiveRecord::Base
  attr_accessible :urgency, :disagree, :content

  belongs_to :relationship
  belongs_to :reverse_relationship
  
  has_one :token, :dependent => :destroy

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
    if sender.reliable_to(recipient) or sender.relationship_With(recipient).allow
      # Build message if the sender is allowed to message the recipient.
      msg = sender.send!( recipient )
      response = Message.build_response(msg.new_token( sender)) if msg
    else
      # Ignore message.
      response = "Ignore"
    end
  end
  
  def new_token( user )
    #create a token attribute and assign the token to it.
    value = ('a'..'z').to_a.shuffle[1..8].join
    Token.create!(:user_id => user.id, :message_id => self.id, :value => value)
    value
  end
  
  def clear_token
    token.destroy
  end
  
  
  private
  
    def self.build_response( token )
      root_url ||= "http://localhost:3000/"
      update_message_path ||= "prioritize"
      link = root_url + update_message_path + "?token=" + token
    end
end
