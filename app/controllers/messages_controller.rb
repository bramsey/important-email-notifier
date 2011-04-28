class MessagesController < ApplicationController
  before_filter :authenticate, :except => [:prioritize]
  before_filter :authorized_user, :except => [:create, :edit, :prioritize]
  before_filter :authorized_sender, :only => [:edit]
  before_filter :authenticate_with_token, :only => [:prioritize]
  
  respond_to :html, :js

  def create
    
    @message  = current_user.send!(params[:recipient], params[:message])
    if @message
      flash[:success] = "Message created!"
    else
      flash[:failure] = "Message not created"
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
      flash[:failure] = "Disagreement failed."
    
    session[:return_to] ||= request.referer
    redirect_back_or root_path
  end
  
  def agree
    @message = Message.find(params[:id])
    @message.agree!
    @message.disagree? ?
      flash[:failure] = "Agreement failed." : 
      flash[:success] = "Agreement noted."

    session[:return_to] ||= request.referer
    redirect_back_or root_path
  end
  
  def show
    @message = Message.find(params[:id])
    
    render 'show'
  end
  
  def prioritize
    
    if @message 
      @message.clear_token
      redirect_to edit_message_path(@message)
    else
      redirect_to root_path
    end
  end
  
  def edit
    render 'edit'
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
      @message ? sign_in( @message.sender ) : @message
    end
end
