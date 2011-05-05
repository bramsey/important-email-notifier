class UsersController < ApplicationController
  before_filter :authenticate,      :except => [:new, :create]
  before_filter :correct_user,      :only => [:edit, :update]
  before_filter :admin_user,        :only => :destroy
  before_filter :already_signed_in, :only => [:new, :create]

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

end
