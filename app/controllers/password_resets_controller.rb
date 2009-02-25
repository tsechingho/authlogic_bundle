class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user
  
  def new
  end

  def edit
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:success] = t('password_resets.flashs.success.create')
      redirect_to root_url
    else
      flash[:error] = t('password_resets.flashs.errors.create')
      render :action => :new
    end
  end

  def update
    if @user.activate!(params[:user])
      flash[:success] = t('password_resets.flashs.success.update')
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = t('password_resets.flashs.errors.update')
      redirect_to root_url
    end
  end
end
