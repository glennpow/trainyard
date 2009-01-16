class UserSessionsController < ApplicationController
  before_filter :not_logged_in_required, :only => [ :new, :create ]
  before_filter :login_required, :only => :destroy

  def new
    @user_session = UserSession.new
    
    store_back if params[:return_to]
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = t(:logged_in, :scope => [ :authenticate ])
      redirect_back_or_default home_path
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = t(:logged_out, :scope => [ :authenticate ])
    redirect_back_or_default login_path
  end
end
