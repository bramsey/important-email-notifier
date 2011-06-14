class EmailService < NotificationService
  
  def notify( msg )
    # Overload NotificationService notify method to email the specified account.
    NotificationsMailer.rank_email(msg).deliver
  end
  
  def description
    "Email notification to: #{username}"
  end
end
