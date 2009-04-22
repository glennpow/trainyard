class Group < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships, :order => 'name ASC', :uniq => true
  has_many :moderators, :through => :memberships, :order => 'name ASC', :source => :user, :conditions => { "#{Membership.table_name}.role" => Role[:administrator] }
  belongs_to :parent_group, :class_name => 'Group', :foreign_key => :parent_group_id
  has_many :child_groups, :class_name => 'Group', :foreign_key => :parent_group_id, :order => 'name ASC', :dependent => :destroy
  has_many :permissions, :dependent => :destroy
  has_many :invites, :dependent => :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  
  searches_on :name
  
  def group
    self
  end
  
  def moderator
    self.moderators.first
  end
  
  def members
    self.users
  end
  
  def has_child?(group)
    self.child_groups.each do |child_group|
      return true if child_group == group
      return true if child_group.has_child?(group)
    end
    return false
  end
  
  def is_child_of?(group)
    if parent_group
      return true if parent_group == group
      return true if parent_group.is_child_of?(group)
    end
    return false
  end
  
  def has_moderator?(user)
    self.moderators.include?(user)
  end
  
  def has_member?(user, with_child_groups = false)
    puts("group.has_member?(#{user.name}, #{with_child_groups})")
    return true if self.users.include?(user)
    puts(" ... not directly")
    if with_child_groups
    puts(" ... checking children")
      self.child_groups.each do |child_group|
        return true if child_group.has_member?(user, with_child_groups)
      end
    end
    puts("not member")
    return false
  end
end