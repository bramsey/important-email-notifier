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
end
