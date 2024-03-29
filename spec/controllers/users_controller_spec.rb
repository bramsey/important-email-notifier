require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'index'" do

    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :name => "Bob", 
                         :alias => "blob", 
                         :email => "another@example.com")
        third  = Factory(:user, :name => "Ben", 
                         :alias => "blen", 
                         :email => "another@example.net")

        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :alias => Factory.next(:alias), 
                                   :email => Factory.next(:email))
        end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should only show unread messages" do
        get :index
        @users[0..2].each do |user|
          #response.should have_selector("li", :content => user.name)
        end
      end

      describe "for non-admin users" do
        it "should not display delete" do
          get :index
          response.should_not have_selector("a", :content => "delete")
        end
      end

      describe "for admin users" do
        before(:each) do
          admin = Factory(:user, :alias => "admn", 
                                 :email => "admin@example.com", :admin => true)
          test_sign_in(admin)
        end

        it "should display delete option" do
          get :index
          response.should have_selector("a", :content => "delete")
        end
      end
    end
  end

  describe "Get 'show'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("span", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("img", :class => "gravatar")
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have a name field" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
    end

    it "should have an alias field" do
      get :new
      response.should have_selector("input[name='user[alias]'][type='text']")
    end
    
    it "should have an email field" do
      get :new
      response.should have_selector("input[name='user[email]'][type='text']")
    end

    it "should have a password field" do
      get :new
      response.should have_selector("input[name='user[password]'][type='password']")
    end

    it "should have a password confirmation field" do
      get :new
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end
  end

  describe "POST 'create'" do

    describe "failure" do

		  before(:each) do
   		 	@attr = { :name => "", :alias => "", :email => "", :password => "",
   		 		:password_confirmation => "" }
  		end

		  it "should not create a user" do
			  lambda do
			  	post :create, :user => @attr
        end.should_not change(User, :count)
  		end

	  	it "should render the 'new' page" do
	  		post :create, :user => @attr
	  		response.should render_template('new')
	  	end
	  end

	  describe "success" do

	    before(:each) do
	      @attr = { :name => "New User", :email => "user@example.com",
	                :alias => "nuser",
	      					:password => "foobar",
	      					:password_confirmation => "foobar" }
      end

      it "should create a user" do
      	lambda do
      		post :create, :user => @attr
     		end.should change(User, :count).by(1)
  		end

  		it "should sign the user in" do
  		  post :create, :user => @attr
  		  controller.should be_signed_in
		  end

  		it "should redirect to the user show page" do
  			post :create, :user => @attr
   			response.should redirect_to(user_path(assigns(:user)))
 			end

 			it "should have a welcome message" do
 			  post :create, :user => @attr
 			  flash[:success].should =~ /welcome to the Notifier/i
		  end
		end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,
                                         :content => "change")
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :email => "", :alias => "", :name => "", :password => "",
                  :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New Name", :alias => "nname", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.alias.should == @attr[:alias]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = Factory(:user, :alias => "wuser", :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "as an admin user" do

      before(:each) do
        @admin = Factory(:user, :alias => "auser", 
                                :email => "admin@example.com", :admin => true)
        test_sign_in(@admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should not destroy itself" do
        lambda do
          delete :destroy, :id => @admin
        end.should_not change(User, :count)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end
end

