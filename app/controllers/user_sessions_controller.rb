class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  # GET /login
  def new
    @user_session = UserSession.new
  end

  # POST /user_session
  def create
    @user_session = UserSession.new(params[:user_session])
    @user_session.save do |result|
      if result
        flash[:success] = t('user_sessions.flashs.success.create')
        redirect_back_or_default account_url
      else
        render :action => :new
      end
    end
  end

  # DELETE /logout
  def destroy
    current_user_session.destroy
    flash[:success] = t('user_sessions.flashs.success.destroy')
    redirect_back_or_default login_url
  end
end
