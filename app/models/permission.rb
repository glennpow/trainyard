class Permission < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :group
  belongs_to :role
  
  validates_presence_of :resource, :action, :group
  
  def self.permitted?(user, action, resource)
    # TODO - Possibly clean this code up...
    return true if user.has_administrator_role? || user.has_administrator_role?(resource.group)
    return true if action == Action.view &&
      Permission.count(:conditions => [
        "#{Permission.table_name}.action_id = ? AND #{Permission.table_name}.resource_id = ? AND #{Permission.table_name}.resource_type = ?",
        action.id, resource.id, resource.class.to_s ]) == 0
    return true if action == Action.edit && user.has_editor_role?(resource.group)
    Membership.count(:include => { :group => :permissions }, :conditions => [
      "#{Membership.table_name}.user_id = ? AND #{Membership.table_name}.role_id = #{Permission.table_name}.role_id AND #{Permission.table_name}.action_id = ? AND #{Permission.table_name}.resource_id = ? AND #{Permission.table_name}.resource_type = ?",
      user, action.id, resource.id, resource.class.to_s ]) > 0
  end
end