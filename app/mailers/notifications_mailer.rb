class NotificationsMailer < ActionMailer::Base
  default :from => "notifier@dev.vybly.com"
  
  def rank_email( msg )
    @url = rank_url(:token => msg.new_token( msg.recipient ), :host => "dev.vybly.com")
    @content = msg.content
    
    mail(:to => msg.received_account.notification_service.username,
         :subject => "New message from #{msg.sender.email}!")
  end
end
