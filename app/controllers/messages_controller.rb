class MessagesController < ApplicationController
  
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
    priority = params[:priority]
    unless (sender.nil? || recipient.nil?)
      if priority
        subject = params[:subject] || "no subject provided"
        msg = Message.initiate_with_priority( sender, recipient, priority, subject)
        notify msg unless msg == "Ignore" || msg.nil?
        @link = "priority notification sent at #{Time.now}"
        render :text => @link
        #render :nothing => true #set this to a success response eventually
      else
        @link = Message.initiate( sender, recipient )
        render :text => @link
      end 
    else
      render :text => 'denied'
    end
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
      token = Token.find_by_value( params[:token] ) unless params[:token].nil?
      @message = token.message if token
      sign_in token.user if @message
    end
    
    def clear_token
      @message.clear_token
    end
    
    def notify( msg )
      user = msg.recipient
      token = msg.new_token( user )
      account = user.accounts.first
      account = Account.first if account.nil? 
      #trigger for preferred user notification goes here.
      #emailing default account is only temporary for use in notification flow.
      Gmail.new( account.username, account.password ) do |gmail|
        url_path = "#{rank_url}?token=#{token}"

        gmail.deliver do
          to user.email
          subject "New message from #{msg.sender.email}!"
          html_part do
            body "Message: #{msg.content} | Please rate the urgency for this message here: #{url_path}"
          end
        end
      end
    end
end
