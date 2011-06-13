class Message < ActiveRecord::Base
  attr_accessible :urgency, :disagree, :content

  belongs_to :relationship
  belongs_to :reverse_relationship
  belongs_to :received_account, :class_name => "Account"
  
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
  
  def self.initiate(sender_email, recipient_email, subject)
    sender = User.find_or_create_by_email( sender_email )
    recipient = User.find_or_create_by_email( recipient_email )
    unless sender == recipient
      rel = sender.relationship_with(recipient)
      received_account = Account.find_by_username(recipient_email)
      allow_flag = (!rel.nil? && rel.allow)
      blocked_flag = (!rel.nil? && rel.blocked)
      unless ((!sender.reliable_to(recipient) && !allow_flag) || blocked_flag)
        # Build message if the sender is allowed to message the recipient.
        msg = sender.send!( recipient )
        msg.update_attributes(:content => subject, :received_account_id => received_account)
        response = Message.build_response(msg.new_token( sender)) if msg
      else
        # Ignore message.
        response = "Ignore"
      end
    end
  end
  
  def self.initiate_with_priority(sender_email, recipient_email, priority, subject)
    sender = User.find_or_create_by_email( sender_email )
    recipient = User.find_or_create_by_email( recipient_email )
    unless sender == recipient
      rel = sender.relationship_with(recipient)
      received_account = Account.find_by_username(recipient_email)
      allow_flag = (!rel.nil? && rel.allow)
      blocked_flag = (!rel.nil? && rel.blocked)
      unless ((!sender.reliable_to(recipient) && !allow_flag) || blocked_flag)
        # Build message if the sender is allowed to message the recipient.
        msg = sender.send!( recipient )
        priority = 1 unless priority.to_i.between?(0,5)
        msg.update_attributes(:content => subject, 
                              :urgency => priority.to_i,
                              :received_account_id => received_account)
        response = msg
      else
        # Ignore message.
        response = "Ignore"
      end
    end
    response
  end
  
  def new_token( user )
    #create a token attribute and assign the token to it.
    value = ('a'..'z').to_a.shuffle[1..8].join
    Token.create!(:user_id => user.id, :message_id => self.id, :value => value)
    value
  end
  
  def clear_token
    token.destroy if token
  end
  
  
  private
    ROOT_URL = 'http://dev.vybly.com/'
  
    def self.build_response( token )
      update_message_path ||= "prioritize"
      link = ROOT_URL + update_message_path + "?token=" + token
    end
end
