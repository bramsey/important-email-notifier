class AccountsController < ApplicationController
  
  require 'gmail'
  
  before_filter :authenticate
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
    @account.active ? @account.active = false : @account.active = true
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
  
  def check
    @user = User.find(params[:user_id])
    @accounts = @user.accounts
    #@messages = []
    
    @accounts.each do |account| 
      Gmail.new( account.username, account.password ) do |gmail|

        gmail.inbox.emails(:unread).each do |email|
          #@messages << {:sender => email.from, :recipient => email.to }
          unless current_user.has_account?( email.from.first )
            @token = Message.initiate( email.from.first, email.to.first )
            send_response( account, email.from.first, email.subject, @token )
          end
        end
      end if account.active
    end
    
    render 'check'
  end

  private

    def authorized_user
      params[:user_id].nil? ? 
        @user = (@account = Account.find(params[:id])).user :
        @user = User.find(params[:user_id])
      redirect_to root_path unless current_user?(@user)
    end
    
    def send_response( account, sender, subj, token )
      Gmail.new( account.username, account.password ) do |gmail|

        gmail.deliver do
          to sender
          subject "Re: #{subj}"
          text_part do
            body "I'm currently in the middle of something and not checking email;" +
              "if you feel it important for your message to reach me right away, please " +
              "click the following link, but note that if I disagree, such notices may be " +
              "less likely to get my attention in the future.  #{token}"
          end
        end
      end
    end

end
