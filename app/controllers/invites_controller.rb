class InvitesController < ApplicationController
  make_resourceful do
    belongs_to :group
    
    member_actions :invitation, :update_invitation
  end
  
  def resourceful_name
    t(:invite, :scope => [ :authenticate ])
  end

  before_filter :login_required, :only => [ :index, :new, :create, :delete, :invitation, :update_invitation ]
  before_filter :check_moderator_of, :except => [ :index, :new, :create, :delete ]
  
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
        t(:group, :scope => [ :authenticate ]),
        { :name => t(:email, :scope => [ :contacts ]), :sort => :email },
        { :name => t(:sent), :scope => [ :content ], :sort => :created_at }
      ]
    end
  end
  
  def invitation
    unless @invite
      logger.error "Invalid Invite Code given."
      flash[:error] = t(:failure_invalid_code, :scope => [ :authenticate, :invites, :invitation ])
      redirect_to intro_path
      return
    end
    @user = User.find_by_email(@invite.email)
    if logged_in?
      if @user != current_user
        logger.error "Invalid User replying to Invite."
        flash[:error] = t(:failure_invalid_user, :scope => [ :authenticate, :invites, :invitation ])
        redirect_to intro_path
        return
      end
    else
      flash[:notice] = t(:create_user, :scope => [ :authenticate, :invites, :invitation ])
      redirect_to new_user_path
    end
  end
  
  def update_invitation
    unless @invite
      logger.error "Invalid Invite given"
      flash[:error] = t(:failure_invalid_code, :scope => [ :authenticate, :invites, :update_invitation ])
      redirect_to intro_path
      return
    end
    @user = User.find_by_email(@invite.email)
    if @user != current_user
      logger.error "Invalid User replying to Invite."
      flash[:error] = t(:failure_invalid_user, :scope => [ :authenticate, :invites, :invitation ])
      redirect_to intro_path
      return
    end
    case params[:commit]
    when t(:accept)
      moderator = @group.moderator
      message = Message.new
      message.from_user = User.admin
      message.to_user = moderator
      message.subject = t(:invite_accepted, :scope => [ :authenticate, :invites, :update_invitation ])
      message.body = t(@invite.moderator ? :moderator_invite_accepted_by : :member_invite_accepted_by, :scope => [ :authenticate, :invites, :update_invitation ], :user => current_user.name, :group => @group.name)
      message.save
      
      if @invite.moderator
        @group.moderator = current_user
      else
        @group.users.push(current_user) unless @group.users.include?(current_user)
      end
      if @group.save
        flash[:notice] = t(@invite.moderator ? :moderator_invite_accepted : :member_invite_accepted, :scope => [ :authenticate, :invites, :update_invitation ], :group => @group.name)
        @invite.destroy
        redirect_to intro_path
      else
        flash[:error] = t(:failure)
        redirect_to intro_path
      end
    when t(:deny)
      moderator = @group.moderator
      message = Message.new
      message.from_user = User.admin
      message.to_user = moderator
      message.subject = t(:invite_denied, :scope => [ :authenticate, :invites, :update_invitation ])
      message.body = t(@invite.moderator ? :moderator_invite_denied_by : :member_invite_denied_by, :scope => [ :authenticate, :invites, :update_invitation ], :user => current_user.name, :group => @group.name)
      message.save
      
      flash[:notice] = t(@invite.moderator ? :moderator_invite_denied : :member_invite_denied, :scope => [ :authenticate, :invites, :update_invitation ], :group => @group.name)
      @invite.destroy
      redirect_to intro_path
    else
      flash[:error] = t(:failure)
      redirect_to intro_path
    end
  end
  
  
  private
  
  def check_moderator_of
    check_moderator(@group)
  end
end
