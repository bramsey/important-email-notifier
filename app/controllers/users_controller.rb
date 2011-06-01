class UsersController < ApplicationController
  require 'starling'
  
  before_filter :authenticate_with_token, :only => [:edit]
  before_filter :authenticate,      :except => [:new, :create, :recover, :reset_pass]
  before_filter :correct_user,      :only => [:edit, :update, :busy]
  before_filter :admin_user,        :only => :destroy
  before_filter :already_signed_in, :only => [:new, :create]
  before_filter :clear_token, :only => [:update]

  def index
    @title = "Contacts"
    current_user.admin? ?
      @users = User.paginate(:page => params[:page]) :
      @users = current_user.contacts.paginate(:page => params[:page])
    #@toDo = "spifify user item styling and content"
  end

  def show
    @user = User.find(params[:id])
    #@microposts = @user.microposts.paginate(:page => params[:page])
    @title = "Profile"
    #@toDo = "Add a message user modal form."
    @filter = true
    @relationship = current_user.relationship_with(@user)
  end

  def new
    @title = "Sign up"
    @user = User.new
    @toDo = "Add check for existing alias."
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Notifier!"
      redirect_to @user
    else
      @title = "Sign up"
      @user.password = ""
      @user.password_confirmation = ""
      render 'new'
    end
  end

  def edit
    @title = "Settings"
    @toDo = "add menu to subnav"
    flash.now[:notice] = "Please set a password and specify an alias to help people " +
      "recognize you more easily." unless current_user.alias
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end
  
  def busy
    @user = User.find(params[:id])
    starling = Starling.new('localhost:22122')
    
    # Flip busy status and queue start/stop of account checkers.
    if @user.busy 
      @user.update_attribute(:busy, false)
      flash[:notice] = "You won't receive notices now."
      @user.accounts.each {|account| starling.set('idler_queue', "stop #{account.id}")}
    else
      @user.update_attribute(:busy, true)
      flash[:notice] = "You will receive notices of important messages now."
      @user.accounts.each do |account|
        if account.active
          starling.set('idler_queue', 
                       "start #{account.id} #{account.username} #{account.password}")
        end
      end
    end
    
    session[:return_to] ||= request.referer
    redirect_back_or root_path
  end

  def destroy
    unless current_user?(User.find(params[:id]))
      User.find(params[:id]).destroy
      flash[:success] = "User destroyed."
    else
      flash[:error] = "Deletion of signed in user not allowed."
    end
    redirect_to users_path
  end
  
  def recipients
    show_relationship(:recipients)
  end

  def senders
    show_relationship(:senders)
  end
  
  def show_relationship(action)
    @title = action.to_s.capitalize
    @user = User.find(params[:id])
    @users = @user.send(action).paginate(:page => params[:page])
    @toDo = "ensure right people are displayed"
    render 'show_relationship'
  end
  
  def recover
    @title = "Recover Account"
  end
  
  def reset_pass
    if params[:user]
      @user = User.find_by_email(params[:user][:email])
      if @user
        send_token @user
        flash[:success] = "The email has been sent"
        redirect_to root_path
      else
        flash[:error] = "No such email found, please ensure the correct address " +
          "is entered."
        redirect_to recover_users_path
      end
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def already_signed_in
      redirect_to(root_path) if signed_in?
    end
    
    def authenticate_with_token
      @token = Token.find_by_value( params[:token] ) unless params[:token].nil?
      sign_in @token.user if @token
    end
    
    def send_token( user ) 
      token = user.new_token
      url_path = "#{edit_user_url(user)}?token=#{token}"
      account = user.accounts.first
      account = Account.first if account.nil? 
      # Change to email with site account instead of user account once set up.
      Gmail.new( account.username, account.password ) do |gmail|

        gmail.deliver do
          to user.email
          subject "Notifier Password Recovery Instructions"
          html_part do
            body "Please click the following link to log in and change your password: <a href=\"#{url_path}\">here</a>."
          end
        end
      end
    end
    
    def clear_token
      @user.clear_tokens
    end

end
