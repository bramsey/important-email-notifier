class NotifoService < NotificationService
  
  def notify( msg )
    # Overload NotificationService notify method to trigger Notifo notification.
    require 'notifo'
    
    user = msg.recipient
    token = msg.new_token( user )

    url_path = "http://localhost:3000/rank?token=#{token}"
    
    notifo = Notifo.new("vybly","notifo_key")
    notifo.post(username, msg.content, "New message from #{msg.sender.email}!", url_path)
    
    
  end
  
  def description
    "Send notification to Notifo account: #{username}"
  end
end
