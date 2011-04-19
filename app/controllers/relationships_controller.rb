class RelationshipsController < ApplicationController
  
  before_filter :authenticate
  
  respond_to :html, :js

  def create
    @user = User.find(params[:relationship][:recipient_id])
    params[:relationship][:sender_id] ? 
      @sender = params[:relationship][:sender_id] :
      @sender = current_user
    @sender.relationships.create!(:recipient_id => @user)
    respond_with @user
  end

end
