require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
        :name => "Example User",
        :alias => "euser",
        :email => "user@example.com",
        :password => "foobar",
        :password_confirmation => "foobar"
    }

  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end
  
  it "should require an alias" do
    no_alias_user = User.new(@attr.merge(:alias => ""))
    no_alias_user.should_not be_valid
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should reject aliases that are too long" do
    long_alias = "a" * 51
    long_alias_user = User.new(@attr.merge(:alias => long_alias))
    long_alias_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate alias" do
    # Put a user with given alias into the database.
    User.create!(@attr)
    user_with_duplicate_alias = User.new(@attr)
    user_with_duplicate_alias.should_not be_valid
  end
  
  it "should reject aliases identical up to case" do
    upcased_alias = @attr[:alias].upcase
    User.create!(@attr.merge(:alias => upcased_alias))
    user_with_duplicate_alias = User.new(@attr)
    user_with_duplicate_alias.should_not be_valid
  end

  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do

      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  
  describe "relationships" do

    before(:each) do
      @user = User.create!(@attr)
      @recipient = Factory(:user)
    end

    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end
    
    it "should have a recipients method" do
      @user.should respond_to(:recipients)
    end
    
    it "should have a send! method" do
      @user.should respond_to(:send!)
    end

    it "should send to another user" do
      @user.send!(@recipient)
      @user.should be_sender(@recipient)
    end

    it "should include the recipient user in the recipients array" do
      @user.send!(@recipient)
      @user.recipients.should include(@recipient)
    end
    
    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end

    it "should have a senders method" do
      @user.should respond_to(:senders)
    end

    it "should include the sender in the senders array" do
      @user.send!(@recipient)
      @recipient.senders.should include(@user)
    end
  end
end

