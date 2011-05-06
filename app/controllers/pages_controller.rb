class PagesController < ApplicationController

  def home
    @title = "Home"
    @slogan = "Ensure only important messages get your attention."
    @content = "Welcome to Notifier!"
    #@toDo = "mark new messages as read when visited"
    
    if signed_in?
      flash.now[:notice] = "Hi! You can get back here easily in the future if you " +
        "set a password and alias on the settings page." unless current_user.alias
    end
  end

  def contact
    @title = "Contact"
    @slogan = "How to reach us."
    @toDo = "Insert contact form and social networking info."
  end

  def about
    @title = "About"
    @slogan = "What the dealyo?"
    @toDo = "Insert detailed about information."
  end

end
