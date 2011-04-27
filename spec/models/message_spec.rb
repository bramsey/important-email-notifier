require 'spec_helper'

describe Message do

  describe "initiation" do
    
    it "should respond to initiate" do
      Message.should respond_to(:initiate)
    end
    
    describe "sender doesn't exist" do
      
      it "should create an account for the sender" do
        
      end
end
