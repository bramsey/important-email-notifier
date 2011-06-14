class EmailService < NotificationService
  
  def notify( msg )
    # Overload NotificationService notify method to email the specified account.
    require 'gmail'
    
    user = msg.recipient
    token = msg.new_token( user )
    #trigger for preferred user notification goes here.
    # Emailing with gmail is only temporary.
    Gmail.new( "vybly.notifier@gmail.com", "email_password" ) do |gmail|
      url_path = "http://dev.vybly.com/rank?token=#{token}"

      gmail.deliver do
        to user.email
        subject "New message from #{msg.sender.email}!"
        html_part do
          body "Message: #{msg.content} | Please rate the urgency for this message here: #{url_path}"
        end
      end
    end
  end
  
  def description
    "Email notification to: #{username}"
  end
end
