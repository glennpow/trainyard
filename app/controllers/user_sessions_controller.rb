class UserSessionsController < ApplicationController
  before_filter :not_logged_in_required, :only => [ :new, :create ]

  def new
    @user_session = UserSession.new
    
    store_back if params[:return_to]
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = t(:logged_in, :scope => [ :authentication ])
      redirect_back_or_default Configuration.default_path
    else
      render :action => :new
    end
  end

  def destroy
    if logged_in?
      current_user_session.destroy
      flash[:notice] = t(:logged_out, :scope => [ :authentication ])
    end
    redirect_back_or_default login_path
  end
end
