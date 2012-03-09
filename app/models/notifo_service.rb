class NotifoService < NotificationService
  require 'notifo'
  
  def notify( msg )
    # Overload NotificationService notify method to trigger Notifo notification.
    
    
    user = msg.recipient
    token = msg.new_token( user )

    url_path = "http://dev.vybly.com/rank?token=#{token}"
    
    #notifo = Notifo.new("billiamram","notifo_key")
    notifo = Notifo.new("vybly", "621f938db528841c27a61f3eeda741de66905e3c")
    notifo.post(username, msg.content, "New message from #{msg.sender.email}!", url_path)
    
    
  end
  
  def description
    "Send notification to Notifo account: #{username}"
  end
end
