class RelationshipsController < ApplicationController
  
  before_filter :authenticate
  
  respond_to :html, :js

  def create
    @user = User.find(params[:relationship][:recipient_id])
    current_user.relationships.create!(:recipient_id => @user)
    respond_with @user
  end

end
