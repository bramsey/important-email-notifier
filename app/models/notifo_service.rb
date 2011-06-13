class NotifoService < NotificationService
  
  def notify( msg )
    # Overload NotificationService notify method to trigger Notifo notification.
  end
  
  def description
    "Send notification to Notifo account: #{username}"
  end
end
