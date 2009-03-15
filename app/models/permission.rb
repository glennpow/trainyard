class Permission < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :group
  belongs_to :role
  
  validates_presence_of :resource, :action_id, :group
  
  def self.permitted?(user, action, resource)
    return false if resource.nil?
    return true if user.has_administrator_role?
    if resource.respond_to?(:group)
      return false unless group = resource.group
      return true if user.has_administrator_role?(group)
    else
      return action == Action.edit && resource.respond_to?(:user) && resource.user == user
    end
    
    Permission.transaction do
      return true if Permission.count(:conditions => [
        "#{Permission.table_name}.action_id = ? AND #{Permission.table_name}.resource_id = ? AND #{Permission.table_name}.resource_type = ?",
        action.id, resource.id, resource.class.to_s ]) == 0

      Permission.count(:include => { :group => :memberships }, :conditions => [
        "#{Membership.table_name}.user_id = ? AND (#{Permission.table_name}.role_id = ? OR #{Membership.table_name}.role_id = ? OR #{Membership.table_name}.role_id = #{Permission.table_name}.role_id) AND #{Permission.table_name}.action_id = ? AND #{Permission.table_name}.resource_id = ? AND #{Permission.table_name}.resource_type = ?",
        user, nil, Role.administrator.id, action.id, resource.id, resource.class.to_s ]) > 0
    end
  end
end