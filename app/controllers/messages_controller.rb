class MessagesController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => :destroy

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

  private

    def authorized_user
      @message = Message.find(params[:id])
      redirect_to root_path unless current_user?(@message.recipient)
    end

end
