class MessagesController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :except => [:create]

  def create
    @message  = current_user.send!(params[:recipient], params[:message])
    if @message
      flash[:success] = "Message created!"
      redirect_to root_path
    else
      @feed_items
      render 'pages/home'
    end
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
  
  private

    def authorized_user
      @message = Message.find(params[:id])
      redirect_to root_path unless current_user?(@message.recipient)
    end
end
