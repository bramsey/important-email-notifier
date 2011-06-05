class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  devise :database_authenticatable, :confirmable, :recoverable, :rememberable, 
         :trackable, :omniauthable #add other devise modules here.
  
  attr_accessor :password
  attr_accessible :alias, :name, :email, :password, :password_confirmation, :remember_me

  has_many :relationships, :foreign_key => "sender_id",
                           :dependent => :destroy
  has_many :recipients, :through => :relationships
  has_many :reverse_relationships, :foreign_key => "recipient_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  has_many :senders, :through => :reverse_relationships
  has_many :accounts, :dependent => :destroy
  has_many :tokens, :dependent => :destroy

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, :length => { :maximum => 50 }
  validates :alias, :length => { :maximum => 50 }  
  validates :email, :presence => true,
                    :format => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }

  # Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 }

  before_save :encrypt_password
  
  def self.find_for_open_id(access_token, signed_in_resource=nil)
    data = access_token['user_info']
    if user = User.find_by_email(data["email"])
      user
    else # Create a user with a stub password.
      User.create!(:email => data["email"], :password => Devise.friendly_token[0,20])
    end
  end

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
    
  
  def sender?(recipient)
    relationships.find_by_recipient_id(recipient)
  end

  def send!(recipient, msg = { :urgency => nil, :content => "" })
    rel = sender?(recipient) || relationships.create!(:recipient_id => recipient.id)
    rel.messages.create!(msg)
  end
  
  def sent_messages
    msgs = []
    relationships.each do |relationship|
      relationship.messages.each { |m| msgs << m }
    end
    msgs
  end
  
  def received_messages
    msgs = []
    reverse_relationships.each do |relationship|
      relationship.messages.each { |m| msgs << m }
    end
    msgs.sort_by {|msg| msg.created_at}.reverse
  end
  
  def messages_from(sender)
    msgs = []
    received_messages.each {|msg| msgs << msg if msg.relationship.sender == sender}
    msgs
  end
  
  def messages_to(recipient)
    msgs = []
    sent_messages.each {|msg| msgs << msg if msg.relationship.recipient == recipient}
    msgs
  end
  
  def contacts
    senders | recipients
  end
  
  def relationship_with(user)
    relationships.find_by_recipient_id(user)
  end
  
  def reverse_relationship_with(user)
    reverse_relationships.find_by_sender_id(user)
  end
  
  def reliable?
    reliable_count = 0
    
    relationships.each {|rel| reliable_count += 1 if rel.reliable?}
    reliable_count > ( relationships.count / 2 )
  end
  
  def reliable_to(user)
    relationship_with(user) ? relationship_with(user).reliable? : true
  end
  
  def trusted_to(user)
    relationship_with(user) ? relationship_with(user).trusted? : false
  end
  
  def reliability_to(user)
    relationship_with(user) ? relationship_with(user).reliability : "Untested"
  end
  
  def has_account?( username )
    accounts.collect {|account| account.username}.include? username
    
    #This might be an optimization.
    #account = Account.find_by_username( username )
    #account ? account.user == self : false
    
  end

  #def feed
  #  Micropost.from_users_followed_by(self)
  #end
  
  def self.find_or_create_by_email( email )
    user = User.find_by_email email
    unless user
      account = Account.find_by_username( email )
      if account
        user = account.user
      else
        user = User.new
        user.email = email
        user.password = random_pass
        user.password_confirmation = user.password
        user.save
      end
    end
    user
  end
      
  def new_token
    #create a token attribute and assign the token to it.
    value = ('a'..'z').to_a.shuffle[1..8].join
    tokens.create!(:value => value)
    value
  end
  
  def clear_tokens
    tokens.each {|t| t.destroy unless t.message_id}
  end

  private

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password) if password
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def self.random_pass
      ('a'..'z').to_a.shuffle[1..6].concat( (0..9).to_a.shuffle[1..3] ).shuffle.join
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
