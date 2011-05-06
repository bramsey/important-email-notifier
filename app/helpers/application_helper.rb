module ApplicationHelper

  def logo
    #image_tag("logo.png", :alt => "Vybly")
    "Notifier"
  end
  
  def siteNav
    content_tag :ul do
      if signed_in?
        link("Contacts", contacts_path) +
        link("Profile", current_user) +
        link("Settings", edit_user_path(current_user))
      else
        #put logged_out links here.
        #link("About", about_path) +
        #link("Contact", contact_path)
      end
    end
  end
  
  def link(label, path)
    if @title == label
      content_tag( :li ) { link_to label, path, :id => "nav_selected" }
    else
      content_tag( :li ) { link_to label, path }
    end
  end
  
  def toDo_block
    if @toDo
      content_tag(:h2, :class => "toDo") { "[ ToDo: " + @toDo + " ]" } 
    end
  end
  
  def content
    @content ? @content : ""
  end
  
  # Return a title on a per-page basis.
  def title
    base_title = "Notifier"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  
  def alias_for( user )
    user.alias ? user.alias : user.email
  end
  
  # put this in the body after a form to set the input focus to a specific control id
  # at end of rhtml file: <%= set_focus_to_id 'form_field_label' %>
  def set_focus_to_id(id)
   javascript_tag("$('#{id}').focus()");
  end
end
