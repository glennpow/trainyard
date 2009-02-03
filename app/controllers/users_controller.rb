class UsersController < ApplicationController
  before_filter :load_objects, :only => [ :index, :show, :destroy, :enable ]
  before_filter :load_user_using_perishable_token, :only => [ :confirm, :reset_password, :update_reset_password ]
  before_filter :not_logged_in_required, :only => [ :new, :create, :activate, :forgot_password, :request_reset_password, :reset_password, :update_reset_password ]
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
    
      if @group
        options[:include] = :memberships
        options[:conditions] = [ "#{Membership.table_name}.group_id = ?", @group.id ]
      end
    end
  end
  
  def show
    @user ||= current_user
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def new
    @user = User.new
    @user_groups = if Configuration.default_user_group_name
      [ Group.find_by_name(Configuration.default_user_group_name, :select => 'id, name') ]
    else
      []
    end
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      Membership.create(:user_id => @user, :role_id => Role.user.id, :group_id => params[:user_group_id]) if params[:user_group_id]
      
      flash[:notice] = t(:success, :scope => [ :authentication, :users, :new ])
      @user.confirm! unless Configuration.email_activation
      redirect_to login_path
    else
      flash[:error] = t(:failure, :scope => [ :authentication, :users, :new ])
      render :action => 'new'
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

  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    
    if @user.update_attributes(params[:user])
      flash[:notice] = t(:object_updated, :object => t(:account, :scope => [ :authentication ]))
      redirect_to :action => 'show', :id => current_user
    else
      flash[:error] = t(:object_not_updated, :object => t(:account, :scope => [ :authentication ]))
      render :action => 'edit'
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
  
  def load_objects
    @group = Group.find_by_id(params[:group_id]) if params[:group_id]
    @user = User.find(params[:id]) if params[:id]
  end

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = t(:failure_invalid_code, :scope => [ :authentication, :passwords, :reset ])
      redirect_to root_url
      return false
    end
  end
end
