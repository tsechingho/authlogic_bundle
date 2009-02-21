class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  # GET /users/1
  # GET /account
  def show
    @user = @current_user
  end

  # GET /users/new
  # GET /signup
  def new
    @user = User.new
  end

  # GET /users/1/edit
  # GET /account/edit
  def edit
    @user = @current_user
  end

  # POST /users
  # POST /account
  def create
    @user = User.new
    
    if @user.signup!(params[:user])
      @user.deliver_activation_instructions!
      flash[:notice] = "Your account has been created. Please check your e-mail for your account activation instructions!"
      redirect_to root_url
    else
      render :action => :new
    end
  end

  # PUT /users/1
  # PUT /account
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
