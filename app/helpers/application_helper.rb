module ApplicationHelper
  
  def logo
    #image_tag("logo.png", :alt => "Vybly")
    "Notifier"
  end
  
  def siteNav
    content_tag :ul do
      link("About") +
      link("Contact") +
      if signed_in?
        content_tag( :li ) { link_to "Users", users_path } +
        content_tag( :li ) { link_to "Profile", current_user } +
        content_tag( :li ) { link_to "Settings", edit_user_path(current_user) } +
        content_tag( :li ) { link_to "Sign out", signout_path, :method => :delete }
      else
        content_tag( :li ) { link_to "Sign in", signin_path }
      end
    end
  end
  
  def link(val)
    if @title == val
      content_tag( :li ) {link_to val, root_path + val.downcase, :id => "nav_selected" }
    else
      content_tag( :li ) { link_to val, root_path + val.downcase }
    end
  end
  
  def toDo_block
    if @toDo
      content_tag(:strong, :class => "toDo") { "[ToDo: " + @toDo + "]" } 
    end
  end
  
  def content
    @content ? @content : ""
  end
  
  # Return a title on a per-page basis.
  def title
    base_title = "Vybly"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
end
