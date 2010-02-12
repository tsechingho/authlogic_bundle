class UsersController < ApplicationController
  ssl_required :show, :new, :edit, :create, :update
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  before_filter :new_user, :only => [:new, :create]
  before_filter :find_user, :only => [:show, :edit, :update]
  filter_access_to :all
  filter_access_to :show, :edit, :update, :attribute_check => true, :load_method => :current_user
  filter_access_to :new, :create do new_user; end

  # GET /users/1
  # GET /account
  def show
  end

  # GET /users/new
  # GET /signup
  def new
  end

  # GET /users/1/edit
  # GET /account/edit
  def edit
  end

  # POST /users
  # POST /account
  def create
    @user.signup!(params[:user]) do |result|
      if result
        @user.deliver_activation_instructions!
        flash[:success] = t('users.flashs.success.create')
        redirect_to root_url
      else
        render :action => :new
      end
    end
  rescue Exception => e
    redirect_to root_url
  end

  # PUT /users/1
  # PUT /account
  def update
    @user.attributes = params[:user]

    @user.save do |result|
      if result
        Rails.cache.delete('user_prefered_language')
        set_language(@user.preferred_language)
        Rails.cache.delete('user_prefered_time_zone')
        set_time_zone(@user.preferred_time_zone)
        flash[:success] = t('users.flashs.success.update')
        redirect_to account_url
      else
        render :action => :edit
      end
    end
  end

  protected

  def find_user
    @user = @current_user
  end

  def new_user
    @user = User.new
  end
end
