module AccountsHelper
  
  def activate_link( account )
    if account.active
      link_to 'De-Activate', activate_account_path(account), 
  			:method => "post", :class => "disagree"
		else
  		link_to 'Activate', activate_account_path(account),
  		  :method => "post", :class => "agree"
		end
	end
	
	def activate_box_for( account )
    active = account.active
    label_tag( "active#{account.id}", "Active?", :class => "switch" ) + 
    check_box_tag( "active#{account.id}", "active#{account.id}", active, 
       :onclick => remote_function(
         :url => toggle_active_account_path(account)
       ))
  end
  
  def reply_box_for( account )
    reply = account.reply
    label_tag( "reply#{account.id}", "Reply?", :class => "switch" ) + 
    check_box_tag( "reply#{account.id}", "reply#{account.id}", reply, 
       :onclick => remote_function(
         :url => toggle_reply_account_path(account)
       ))
  end
	
	def current_user?(user)
    user == current_user
  end
end
