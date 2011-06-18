class PagesController < ApplicationController

  def home
    @title = "Home"
    @slogan = "Safely ignore distractions."
    #@content = "Welcome to Notifier!"
    #@toDo = rank_url(:token => "bam!", :host => "dev.vybly.com")
    
  end

  def contact
    @title = "Contact"
    #@slogan = "Have a question or comment?."
    #@toDo = "Insert contact form and social networking info."
  end

  def about
    @title = "About"
    @slogan = "What's the deal?"
    @toDo = "Insert detailed about information."
  end

end
