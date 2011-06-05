class RelationshipsController < ApplicationController
  
  before_filter :authenticate_user!
  
  respond_to :html, :js

  def create
    @user = User.find(params[:relationship][:recipient_id])
    params[:relationship][:sender_id] ? 
      @sender = params[:relationship][:sender_id] :
      @sender = current_user
    @sender.relationships.create!(:recipient_id => @user)
    respond_with @user
  end
  
  def toggle_allow
    @relationship = Relationship.find(params[:id])
    if @relationship
      @relationship.allow ?
        @relationship.allow = false : @relationship.allow = true
      @relationship.save ?
        flash.now[:success] = "Toggled allow" : flash.now[:error] = "Toggle failed"
    end
    render :nothing => true
  end
  
  def toggle_blocked
    @relationship = Relationship.find(params[:id])
    if @relationship
      @relationship.blocked ?
        @relationship.blocked = false : @relationship.blocked = true
      @relationship.save
    end
    render :nothing => true
  end
end
