class AccountsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

  def create
    @account  = current_user.accounts.build(params[:account])
    if @account.save
      flash[:success] = "account created!"
      redirect_to root_path
    else
      render 'pages/home'
    end
  end

  def destroy
    @account.destroy
    redirect_back_or root_path
  end
  
  def index
    @user = User.find(params[:user_id])
    @accounts = @user.accounts
  end

  private

    def authorized_user
      @account = account.find(params[:id])
      redirect_to root_path unless current_user?(@account.user)
    end

end
