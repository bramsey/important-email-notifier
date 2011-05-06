class MessagesController < ApplicationController
  require 'gmail'
  
  before_filter :authenticate, :except => [:prioritize, :init, :rank]
  before_filter :authorized_user, :except => [:create, :edit, :prioritize, :init, :update, :rank]
  before_filter :authorized_sender, :only => [:edit, :update]
  before_filter :authenticate_with_token, :only => [:prioritize, :rank]
  before_filter :clear_token, :only => [:agree, :disagree, :update]
  
  respond_to :html, :js, :xml

  def create
    
    @message  = current_user.send!(params[:recipient], params[:message])
    if @message
      flash[:success] = "Message created!"
    else
      flash[:error] = "Message not created"
    end
    
    respond_with current_user
  end

  def destroy
    @message.destroy
    redirect_back_or root_path
  end
  
  def index
    @user = User.find(params[:user_id])
    @messages = @user.received_messages.paginate(:page => params[:page])
  end
  
  def disagree
    @message.disagree!
    @message.disagree? ? 
      flash[:success] = "Disagreement noted." : 
      flash[:error] = "Disagreement failed."
    
    session[:return_to] ||= request.referer
    redirect_back_or root_path
  end
  
  def agree
    @message = Message.find(params[:id])
    @message.agree!
    @message.disagree? ?
      flash[:error] = "Agreement failed." : 
      flash[:success] = "Agreement noted."

    session[:return_to] ||= request.referer
    redirect_back_or root_path
  end
  
  def show
    @message = Message.find(params[:id])
    
    render 'show'
  end
  
  def prioritize
    @message ? 
      redirect_to( edit_message_path( @message ) ):
      redirect_to( root_path )
  end
  
  def rank
    @message ? 
      redirect_to( message_path( @message ) ):
      redirect_to( root_path )
  end
  
  def init
    sender = params[:sender]
    recipient = params[:recipient]
    @link = Message.initiate( sender, recipient )
    
    render 'init'
  end
  
  def edit
    @message = Message.find(params[:id])
    render 'edit'
  end
  
  def update
    @message = Message.find(params[:id])
    if @message.update_attributes(params[:message])
      flash[:success] = "Message sent."
      #ToDo: insert trigger for notification here.
      notify( @message )
      redirect_to @message
    else
      @title = "Send message"
      flash[:error] = "Message not sent."
      render 'edit'
    end
  end
  
  private

    def authorized_user
      @message = Message.find(params[:id])
      redirect_to root_path unless current_user?(@message.recipient)
    end
    
    def authorized_sender
      @message = Message.find(params[:id])
      redirect_to root_path unless current_user?(@message.sender)
    end
      
    def authenticate_with_token
      @message = Message.find_by_token( params[:token] ) unless params[:token].nil?
      if @message
        ( params[:action] == "prioritize" ) ? 
          sign_in( @message.sender ) : 
          sign_in( @message.recipient )
      end
    end
    
    def clear_token
      @message.clear_token
    end
    
    def notify( msg )
      token = msg.new_token
      user = msg.recipient
      account = user.accounts.first
      account = Account.first if account.nil? 
      #trigger for preferred user notification goes here.
      #emailing default account is only temporary for use in notification flow.
      Gmail.new( account.username, account.password ) do |gmail|
        url_path = "http://localhost:3000/rank?token=#{token}"

        gmail.deliver do
          to user.email
          subject "New message from #{msg.sender.email}!"
          html_part do
            body "<p>Message: #{msg.content}</p><p>Please rate the urgency for this message <a href=\"#{url_path}\">here</a>."
          end
        end
      end
    end
end
