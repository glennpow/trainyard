class InvitesController < ApplicationController
  make_resource_controller do
    belongs_to :group
    
    member_actions :invitation, :update_invitation
  end
  
  def resourceful_name
    t(:invite, :scope => [ :authentication ])
  end

  before_filter :login_required, :only => [ :update_invitation ]
  before_filter :check_invite, :only => [ :invitation, :update_invitation ]
  before_filter :check_moderator_of_group, :except => [ :index, :new, :create, :delete ]
  
  def current_object
    @current_object ||= if params[:id]
      current_model.find(params[:id])
    elsif params[:invite_code]
      current_model.find_by_invite_code(params[:invite_code])
    end
  end
  
  def index
    respond_with_indexer do |options|
      optinos[:default_sort] = :created_at
      options[:headers] = [
        t(:group, :scope => [ :authentication ]),
        { :name => t(:email, :scope => [ :contacts ]), :sort => :email },
        { :name => t(:sent), :scope => [ :content ], :sort => :created_at }
      ]
    end
  end
  
  def invitation
    @user = User.find_by_email(@invite.email)
    if @user
      if logged_in?
        if @user != current_user
          flash[:error] = t(:failure_invalid_user, :scope => [ :authentication, :invites, :invitation ])
          redirect_to Configuration.default_path
          return
        end
      end
    else
      flash[:notice] = t(:create_user, :scope => [ :authentication, :invites, :invitation ])
      redirect_to new_user_path
    end
  end
  
  def update_invitation
    @user = User.find_by_email(@invite.email)
    if @user != current_user
      flash[:error] = t(:failure_invalid_user, :scope => [ :authentication, :invites, :invitation ])
      redirect_to Configuration.default_path
      return
    end
    case params[:commit]
    when t(:accept)
      message = Message.new
      message.from_user = User.administrator
      message.to_user = @invite.inviter
      message.subject = t(:invite_accepted, :scope => [ :authentication, :invites, :update_invitation ])
      message.body = t(:member_invite_accepted_by, :scope => [ :authentication, :invites, :update_invitation ], :user => current_user.name, :group => @group.name)
      message.save
      
      if Membership.create(:user_id => current_user, :role_id => Role.user.id, :group_id => @invite.group_id)
        flash[:notice] = t(:member_invite_accepted, :scope => [ :authentication, :invites, :update_invitation ], :group => @group.name)
        @invite.destroy
        redirect_to user_groups_path(current_user)
      else
        flash[:error] = t(:failure)
        redirect_to user_messages_path(current_user)
      end
    when t(:deny)
      message = Message.new
      message.from_user = User.administrator
      message.to_user = @invite.inviter
      message.subject = t(:invite_denied, :scope => [ :authentication, :invites, :update_invitation ])
      message.body = t(:member_invite_denied_by, :scope => [ :authentication, :invites, :update_invitation ], :user => current_user.name, :group => @group.name)
      message.save
      
      flash[:notice] = t(:member_invite_denied, :scope => [ :authentication, :invites, :update_invitation ], :group => @group.name)
      @invite.destroy
      redirect_to user_groups_path(current_user)
    else
      flash[:error] = t(:failure)
      redirect_to user_messages_path(current_user)
    end
  end
  
  
  private
  
  def check_invite
    unless @invite
      flash[:error] = t(:failure_invalid_code, :scope => [ :authentication, :invites, :update_invitation ])
      redirect_to Configuration.default_path
      return false
    end
  end
  
  def check_moderator_of_group
    check_moderator_of(@group)
  end
end
