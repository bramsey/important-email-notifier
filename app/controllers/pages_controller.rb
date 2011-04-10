class PagesController < ApplicationController

  def home
    @title = "Home"
    @slogan = "Ensure only the right messages get your attention."
    @content = "Welcome to Notifier!"
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
