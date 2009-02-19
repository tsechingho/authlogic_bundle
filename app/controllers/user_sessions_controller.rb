class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  # GET /login
  def new
    @user_session = UserSession.new
  end

  # POST /login
  def create
    @user_session = UserSession.new(params[:user_session])
    @user_session.save do |result|
      if result
        flash[:notice] = "Login successful!"
        redirect_back_or_default account_url
      else
        render :action => :new
      end
    end
  end

  # DELETE /logout
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default login_url
  end
end
