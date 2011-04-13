class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :alias, :name, :email, :password, :password_confirmation

  has_many :relationships, :foreign_key => "sender_id",
                           :dependent => :destroy
  has_many :recipients, :through => :relationships
  has_many :reverse_relationships, :foreign_key => "recipient_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  has_many :senders, :through => :reverse_relationships

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, :presence => true,
                   :length => { :maximum => 50 }
  validates :alias, :presence => true,
                    :length => { :maximum => 50 },
                    :uniqueness => { :case_sensitive => false }   
  validates :email, :presence => true,
                    :format => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }

  # Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 }

  before_save :encrypt_password

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

  def send!(recipient)
    relationships.create!(:recipient_id => recipient.id)
  end

  #def feed
  #  Micropost.from_users_followed_by(self)
  #end

  private

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
