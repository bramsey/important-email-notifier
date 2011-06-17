class AccountsController < ApplicationController
  require 'starling'
  
  before_filter :authenticate_user!
  before_filter :authorized_user, :except => [:create]
  after_filter  :update_listener, :only => [:toggle_active, :toggle_reply]

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
  
  def edit
    @account = Account.find(params[:id])
  end
  
  def update
    @account = Account.find(params[:id])
    if params[:account][:notification_service_id].is_a?(String)
      params[:account][:notification_service_id] = params[:account][:notification_service_id].to_i
    end
    
    RAILS_DEFAULT_LOGGER.error params[:account][:notification_service_id]
    @account.update_attributes(params[:account]) ?
      flash[:success] = "Account updated." :
      flash[:error] = "Error updating account."
    redirect_to user_accounts_path( current_user )
  end
  
  def toggle_active
    @account = Account.find(params[:id])
    
    @account.update_attribute(:active, !@account.active)

    render :nothing => true
  end
  
  def toggle_reply
    @account = Account.find(params[:id])
    
    @account.update_attribute(:reply, !@account.reply)

    render :nothing => true
  end
  
  def update_service
    @account = Account.find(params[:id])
    service_id = params[:service_id]
    @account.update_attribute(:notification_service_id, service_id.to_i) unless service_id.nil?
    
    render :nothing => true
  end
  
  def index
    @user = User.find(params[:user_id])
    @title = "Accounts"
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
    
    def update_listener
      starling = Starling.new('localhost:22122')
      if @account.active
        starling.set('idler_queue', 
          "start #{@account.id} #{@account.username}" +
          " #{@account.token} #{@account.secret} #{@account.reply}") if @account.user.busy 
      else
        starling.set('idler_queue', "stop #{@account.id}")
      end
    end

end
