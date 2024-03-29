require 'spec_helper'

describe Message do

  describe "initiation" do
    before(:each) do
      @sender = User.find_or_create_by_email( "sender@example.com" )
      @recipient = User.find_or_create_by_email( "recipient@example.com" )
    end
    
    it "should respond to initiate" do
      Message.should respond_to(:initiate)
    end
    
    describe "for new users" do
      
      it "should return the url for the client response" do
        response = Message.initiate( "new@example.com", @recipient.email)
        response.should include("http")
      end
    end
    
    describe "for existing users" do
      
      it "should return the url for the client response" do
        response = Message.initiate( @sender.email, @recipient.email )
        response.should include("http")
      end
      
      it "should return Ignore flag if the sender is unreliable" do
        11.times do
          msg = @sender.send! @recipient
          msg.disagree!
        end
        response = Message.initiate( @sender.email, @recipient.email )
        response.should == "Ignore"
      end
    end
    
    it "should create a message from the sender to the recipient" do
      lambda do
        Message.initiate( @sender.email, @recipient.email )
      end.should change( Message, :count )
    end
    
    describe "tokens" do
      
      it "should have a new_token method" do
        msg = @sender.send!( @recipient )
        msg.should respond_to(:new_token)
      end
    
      it "should create a token for the new message" do
        Message.initiate( @sender.email, @recipient.email )
        Message.last.token.should_not be_nil
      end
    end
  end 
end
