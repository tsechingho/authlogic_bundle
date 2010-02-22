class PasswordResetsController < ApplicationController
  ssl_required :edit, :update
  ssl_allowed :new, :create
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user

  # GET /password_resets/new
  def new
  end

  # GET /password_resets/1/edit
  def edit
  end

  # POST /password_resets
  def create
    @user = User.active.find_by_email(params[:user][:email]) if params[:user]

    if @user
      @user.deliver_password_reset_instructions!
      flash[:success] = ft('success')
      redirect_to root_url
    else
      flash[:error] = ft('error')
      render :action => :new
    end
  end

  # PUT /password_resets/1
  def update
    if @user.reset_password_with_params!(params[:user])
      flash[:success] = ft('success')
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])

    unless @user
      flash[:error] = ft('error')
      redirect_to root_url
    end
  end
end
