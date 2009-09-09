class ActivationsController < ApplicationController
  ssl_required :new, :create
  before_filter :require_no_user, :only => [:new, :create]

  # GET /register/:activation_code
  def new
    @user = User.find_using_perishable_token(params[:activation_code], 1.week) || (raise Exception)
    raise Exception if @user.active?
  rescue Exception => e
    redirect_to root_url
  end

  # POST /activate/:id
  def create
    @user = User.find_by_login(params[:id])
    raise Exception if @user.active?

    @user.activate!(params[:user]) do |result|
      if result
        @user.deliver_activation_confirmation!
        flash[:success] = t('activations.flashs.success.create')
        redirect_to edit_account_url
      else
        render :action => :new
      end
    end
  rescue Exception => e
    redirect_to root_url
  end
end