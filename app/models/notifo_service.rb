class NotifoService < NotificationService
  require 'notifo'
  
  def notify( msg )
    # Overload NotificationService notify method to trigger Notifo notification.
    
    
    user = msg.recipient
    token = msg.new_token( user )

    url_path = "http://dev.vybly.com/rank?token=#{token}"
    
    #notifo = Notifo.new("billiamram","notifo_key")
    notifo = Notifo.new("vybly", "notifo_key")
    notifo.post(username, msg.content, "New message from #{msg.sender.email}!", url_path)
    
    
  end
  
  def description
    "Send notification to Notifo account: #{username}"
  end
end
