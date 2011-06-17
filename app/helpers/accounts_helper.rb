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
  
  def select_box_for( account )
    select_tag( "notification_service_#{account.id}", 
                options_from_collection_for_select(account.user.notification_services, 
                                                   :id, 
                                                   :description, account.notification_service_id),
                :onchange => remote_function(
                  :url => update_service_account_path(account),
                  :with => "'service_id=' + this.value"
                ))
  end
	
	def current_user?(user)
    user == current_user
  end
end
