class AccountsController < ApplicationController
  require 'starling'
  
  before_filter :authenticate_user!
  before_filter :authorized_user, :except => [:create]

  def create
    @account  = current_user.accounts.build(params[:account])
    if @account.save
      flash[:success] = "account created!"
      redirect_to user_accounts_path( current_user )
    else
      render 'pages/home'
    end
  end

  def destroy
    @account.destroy ?
      flash[:success] = "Account deleted." :
      flash[:error] = "Error deleting account."
    redirect_to user_accounts_path( current_user ) 
  end
  
  def update
    @account = Account.find(params[:id])
    @account.update_attributes(params[:account]) ?
      flash[:success] = "Account updated." :
      flash[:error] = "Error updating account."
    redirect_to user_accounts_path( current_user )
  end
  
  def activate
    @account = Account.find(params[:id])
    starling = Starling.new('localhost:22122')
    if @account.active 
      @account.active = false 
      starling.set('idler_queue', "stop #{@account.id}")
    else
      @account.active = true
      starling.set('idler_queue', 
        "start #{@account.id} #{@account.username} #{@account.token} #{@account.secret}") if @account.user.busy
    end
      
    @account.save
    
    session[:return_to] ||= request.referer
    redirect_back_or root_path
  end
  
  def index
    @user = User.find(params[:user_id])
    @accounts = @user.accounts
    
    flash.now[:notice] = "Please add an account to help you avoid " +
      "unimportant interruptions." if @accounts.empty?
  end
  
  def new
    @account = Account.new
  end
  

  private

    def authorized_user
      params[:user_id].nil? ? 
        @user = (@account = Account.find(params[:id])).user :
        @user = User.find(params[:user_id])
      redirect_to root_path unless current_user?(@user)
    end

end
