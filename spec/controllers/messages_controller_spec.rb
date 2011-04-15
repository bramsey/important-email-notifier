require 'spec_helper'

describe MessagesController do

  render_views

  describe "access control" do

    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'destroy'" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @recipient = Factory(:user, :alias => Factory.next(:alias), :email => Factory.next(:email))
    end

    describe "success" do

      before(:each) do
        @attr = {:urgency => 2, :content => "Lorem ipsum" }
      end

      it "should create a message" do
        lambda do
          post :create, :recipient => @recipient, :message => @attr
        end.should change(Message, :count).by(1)
      end

      it "should redirect to the home page" do
        post :create, :recipient => @recipient, :message => @attr
        response.should redirect_to(root_path)
      end

      it "should have a flash message" do
        post :create, :recipient => @recipient, :message => @attr
        flash[:success].should =~ /message created/i
      end
    end
  end

  describe "DELETE 'destroy'" do

    describe "for an unauthorized user" do

      before(:each) do
        @user = Factory(:user)
        @recipient = Factory(:user, :alias => "recip", :email => Factory.next(:email))
        @relationship = @user.relationships.create(:recipient_id => @recipient.id)
        wrong_user = Factory(:user, :alias => "uss", :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @message = Factory(:message, :relationship => @relationship)
      end

      it "should deny access" do
        delete :destroy, :id => @message
        response.should redirect_to(root_path)
      end
    end

    describe "for an authorized user" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        @recipient = Factory(:user, :alias => "recips", :email => "bob@example.com")
        @message = @user.send!(@recipient, "test")
      end
      
      #put destroy test here.
    end
  end
end
