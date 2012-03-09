class NotificationServicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorized_user
  require 'notifo'
  
  def index
    @user = User.find(params[:user_id])
    @notification_services = @user.notification_services
  end
  
  def new
    case params[:type]
    when "EmailService"
      @notification_service = NotificationService.new(:user_id => current_user.id, 
                                                      :type => "EmailService")
    when "NotifoService"
      @notification_service = NotificationService.new(:user_id => current_user.id,
                                                      :type => "NotifoService")
    else
      @notification_service = nil
    end
  end
  
  def create
    @notification_service  = NotificationService.create(params[:notification_service])
    if @notification_service.save
      flash[:success] = "Service created!"
      notifo = Notifo.new("vybly","621f938db528841c27a61f3eeda741de66905e3c")
      response = notifo.subscribe_user(@notification_service.username)
      RAILS_DEFAULT_LOGGER.error response
      redirect_to user_notification_services_path( current_user )
    else
      render 'pages/home'
    end
  end
  
  def destroy
    @notification_service.destroy
    redirect_back_or user_notification_services_path(current_user) 
  end
  
  private
  
    def authorized_user
      if params[:user_id].nil?
        if !params[:notification_service].nil?
          @user = User.find(params[:notification_service][:user_id])
        else
          @user = (@notification_service = NotificationService.find(params[:id])).user
        end
      else
        @user = User.find(params[:user_id])
      end
      redirect_to root_path unless current_user?(@user)
    end
end
