require 'spec_helper'

describe Relationship do

  before(:each) do
    @sender = Factory(:user)
    @recipient = Factory(:user, :alias => "fuser", :email => Factory.next(:email))

    @relationship = @sender.relationships.build(:recipient_id => @recipient.id)
  end

  it "should create a new instance given valid attributes" do
    @relationship.save!
  end
  
  describe "send methods" do

    before(:each) do
      @relationship.save
    end

    it "should have a sender attribute" do
      @relationship.should respond_to(:sender)
    end

    it "should have the right sender" do
      @relationship.sender.should == @sender
    end

    it "should have a recipient attribute" do
      @relationship.should respond_to(:recipient)
    end

    it "should have the right recipient user" do
      @relationship.recipient.should == @recipient
    end
  end
  
  describe "validations" do

    it "should require a sender_id" do
      @relationship.sender_id = nil
      @relationship.should_not be_valid
    end

    it "should require a recipient_id" do
      @relationship.recipient_id = nil
      @relationship.should_not be_valid
    end
  end
  
  describe "reliability" do
    before(:each) do
      15.times do
        @sender.send!(@recipient, 1, "test")
      end
      @relationship = @sender.relationships.first
      @msgs = @relationship.messages
    end
    
    it "should have reliable? method" do
      @relationship.should respond_to(:reliable?)
    end
    
    it "should be reliable if fewer than 2 disagreements are present" do
      @msgs.first.disagree!
      @msgs.second.disagree!
      @relationship.reliable?.should be_true
    end
    
    it "should be unreliable if 3 disagreements are found before 10 agreements" do
      @msgs.first.disagree!
      @msgs.second.disagree!
      @msgs[11].disagree!
      @relationship.reliable?.should_not be_true
    end
    
    it "should be reliable if 10 agreements occur in a row" do
      @msgs.first.disagree!
      @msgs.second.disagree!
      @msgs[12].disagree!
      @relationship.reliable?.should be_true
    end
  end
end
