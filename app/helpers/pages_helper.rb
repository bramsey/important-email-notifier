module PagesHelper
  
  def edit_user_link
    link_to 'set a password', edit_user_path( current_user )
  end
end
