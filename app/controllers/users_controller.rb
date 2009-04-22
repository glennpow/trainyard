class UsersController < ApplicationController
  make_resource_controller(:actions => [ :show, :new, :create, :edit, :update ]) do
    belongs_to :group, :organization
    
    member_actions :destroy, :enable

    before :new do
      group_names = Configuration.default_user_group_name || Configuration.default_user_group_names
      @user_groups = group_names ? Group.all(:select => 'id, name', :conditions => { :name => group_names }) : []
    end
    
    after :create do
      Membership.create(:user => @user, :role => Role[:user], :group_id => params[:user_group_id]) if params[:user_group_id]
      @user.confirm! unless Configuration.email_activation
    end
    
    response_for :create do |format|
      format.html { redirect_to login_path }
    end
    
    before :edit do
      @user = current_user
    end
  
    before :update do
      @user = current_user
    end
    
    response_for :update do |format|
      format.html { redirect_to :action => 'show', :id => current_user }
    end
  end
  
  def resourceful_name
    t(:user, :scope => [ :authentication ])
  end
  
  before_filter :load_user_using_perishable_token, :only => [ :confirm, :reset_password, :update_reset_password ]
  before_filter :not_logged_in_required, :only => [ :new, :create, :confirm, :forgot_password, :request_reset_password, :reset_password, :update_reset_password ]
  before_filter :login_required, :only => [ :edit, :edit_password, :update, :update_password ]
  before_filter :check_administrator_role, :only => [ :destroy, :enable ]
  
  def index
    respond_with_indexer do |options|
      if has_administrator_role?
        options[:default_sort] = :login
        options[:headers] = [
          { :name => t(:login, :scope => [ :authentication ]), :sort => :login },
          { :name => t(:name), :sort => :name, :order => 'users.name' },
          t(:primary_email, :scope => [ :authentication ]),
          tp(:group, :scope => [ :authentication ]),
          t(:status)
        ]
      else
        options[:default_sort] = :name
        options[:headers] = [
          { :name => t(:name), :sort => :name, :order => 'users.name' }
        ]
      end
      options[:search] = true
    
      if @organization
        @group = @organization.group
      end
      if @group
        options[:include] = :memberships
        options[:conditions] = [ "#{Membership.table_name}.group_id = ?", @group.id ]
      end
    end
  end
  
  def confirm
    if (!params[:id].blank?) && @user && !@user.confirmed?
      @user.confirm!
      flash[:notice] = t(:success, :scope => [ :authentication, :users, :confirm ])
      redirect_to login_path
    elsif params[:id].blank?
      flash[:error] = t(:failure_no_activation_code, :scope => [ :authentication, :users, :confirm ])
      redirect_to new_user_path 
    else 
      flash[:error] = t(:failure_already_activated, :scope => [ :authentication, :users, :confirm ])
      redirect_to login_path
    end
  end

  def destroy
    if @user.update_attribute(:active, false)
      flash[:notice] = t(:success, :scope => [ :authentication, :users, :disable ])
    else
      flash[:error] = t(:failure, :scope => [ :authentication, :users, :disable ])
    end
    redirect_to :action => 'index'
  end
  
  def enable
    if @user.update_attribute(:active, true)
      flash[:notice] = t(:success, :scope => [ :authentication, :users, :enable ])
    else
      flash[:error] = t(:failure, :scope => [ :authentication, :users, :enable ])
    end
    redirect_to :action => 'index'
  end
  
  def edit_password
  end
  
  def update_password
    return unless request.post?
    @user = current_user
    
    if @user.valid_password?(params[:old_password])
      if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
        @user.password_confirmation = params[:password_confirmation]
        @user.password = params[:password]        
        if @user.save
          flash[:notice] = t(:object_updated, :object => t(:password, :scope => [ :authentication ]))
          redirect_to user_path(@user)
          return
        else
          flash[:error] = t(:object_not_updated, :object => t(:password, :scope => [ :authentication ]))
        end
      else
        flash[:error] = t(:failure_do_not_match, :scope => [ :authentication, :passwords, :edit ])
        @old_password = params[:old_password]
      end
    else
      flash[:error] = t(:failure_incorrect, :scope => [ :authentication, :passwords, :edit ])
    end 
    render :action => 'edit_password'
  end
  
  def forgot_password
  end

  def request_reset_password
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      @user.forgot_password!
      flash[:notice] = t(:success, :scope => [ :authentication, :passwords, :forgot ])
      redirect_to login_path
    else
      flash[:error] = t(:failure_no_user, :scope => [ :authentication, :passwords, :forgot ])
      render :action => 'forgot_password'
    end  
  end
  
  def reset_password
  end
    
  def update_reset_password
    if params[:password].blank?
      flash[:error] = t(:failure_blank, :scope => [ :authentication, :passwords, :reset ])
      render :action => 'reset_password', :id => params[:id]
      return
    end
    if (params[:password] == params[:password_confirmation])
      @user.password_confirmation = params[:password_confirmation]
      @user.password = params[:password]
      if @user.save
        flash[:notice] = t(:success, :scope => [ :authentication, :passwords, :reset ])
      else
        flash[:error] = t(:failure, :scope => [ :authentication, :passwords, :reset ])
      end
    else
      flash[:error] = t(:failure_do_not_match, :scope => [ :authentication, :passwords, :edit ])
      render :action => 'reset_password', :id => params[:id]
      return
    end  
    redirect_to login_path
  rescue
    flash[:error] = t(:failure_invalid_code, :scope => [ :authentication, :passwords, :reset ])
    redirect_to new_user_path
  end
  
  def update_locale
    locale = Locale.find(params[:locale])
    if logged_in?
      current_user.locale = locale
      current_user.save
    end
    session[:locale] = locale.code
    redirect_to :back
  end
  
  
  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = t(:failure_invalid_code, :scope => [ :authentication, :passwords, :reset ])
      redirect_to root_url
      return false
    end
  end
end
