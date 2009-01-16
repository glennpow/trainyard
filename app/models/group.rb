class Group < ActiveRecord::Base
  belongs_to :moderator, :class_name => 'User'
  belongs_to :parent_group, :foreign_key => :parent_group_id, :class_name => 'Group'
  has_many :child_groups, :foreign_key => :parent_group_id, :class_name => 'Group', :dependent => :destroy, :order => 'name ASC'
  has_and_belongs_to_many :users, :order => 'name ASC'
  has_many :invites, :dependent => :destroy
  
  validates_presence_of :name, :moderator
  validates_uniqueness_of :name, :case_sensitive => false
  
  searches_on :name
  
  def group
    self
  end
  
  def parent_group_name
    self.parent_group.name if self.parent_group
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
    self.moderator == user
  end
  
  def has_member?(user)
    return true if self.users.include?(user)
    self.child_groups.each do |child_group|
      return true if child_group.has_member?(user)
    end
    return false
  end
  
  def has_moderator_or_member?(user)
    return has_moderator?(user) || has_member?(user)
  end
end