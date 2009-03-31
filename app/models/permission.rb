class Permission < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :group
  
  validates_presence_of :resource, :action, :group
  
  class << self
    extend ActiveSupport::Memoizable
    
    def permitted?(user, action, resource)
      return false if resource.nil?
      return true if user.has_administrator_role?
      if resource.respond_to?(:group)
        return false unless resource.group
        return true if user.has_administrator_role?(resource.group)
      end
      default_permission = true
      if resource.respond_to?(:user)
        return true if action == Action.edit && resource.user == user
        default_permission = false
      end

      Permission.transaction do
        return default_permission if Permission.count(:conditions => [
          "#{Permission.table_name}.action = ? AND #{Permission.table_name}.resource_id = ? AND #{Permission.table_name}.resource_type = ?",
          action, resource.id, resource.class.to_s ]) == 0

        Permission.count(:include => { :group => :memberships }, :conditions => [
          "#{Membership.table_name}.user_id = ? AND (#{Permission.table_name}.role = ? OR #{Membership.table_name}.role = ? OR #{Membership.table_name}.role = #{Permission.table_name}.role) AND #{Permission.table_name}.action = ? AND #{Permission.table_name}.resource_id = ? AND #{Permission.table_name}.resource_type = ?",
          user, nil, Role[:administrator], action, resource.id, resource.class.to_s ]) > 0
      end
    end
    memoize :permitted?
  end
end