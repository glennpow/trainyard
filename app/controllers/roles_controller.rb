class RolesController < ApplicationController
  before_filter :check_group_and_user
  before_filter :check_role, :only => [ :update, :destroy ]
 
  def index
    @assigned_roles = @user.roles(@group)
    @available_roles = Role.all - @assigned_roles
  end
 
  def update
    unless @user.has_role?(@role, @group)
      membership = Membership.new(:user => @user, :group => @group, :role => @role)
      if membership.save
        flash[:notice] = t(:object_updated, :object => t(:role, :scope => [ :authentication ]))
      else
        flash[:error] = t(:object_not_updated, :object => t(:role, :scope => [ :authentication ]))
        logger.warn("Failed to update #{t(:role, :scope => [ :authentication ])}: #{membership.errors.full_messages.to_sentence}")
      end
    end
    redirect_to :back
  end
  
  def destroy
    memberships = Membership.destroy_all(:user_id => @user, :group_id => @group, :role => @role)
    flash[:notice] = t(:object_updated, :object => t(:role, :scope => [ :authentication ]))
    redirect_to :back
  end
  
  
  private
  
  def check_group_and_user
    @group = Group.find(params[:group_id]) if params[:group_id]
    check_condition(is_moderator_of?(@group) && @user = User.find(params[:user_id]))
  end
  
  def check_role
    check_condition(@role = Role.find(params[:id]))
  end
end
