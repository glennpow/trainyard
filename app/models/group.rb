class Group < ActiveRecord::Base
  acts_as_tree
  
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships, :order => 'name ASC', :uniq => true
  has_many :moderators, :through => :memberships, :order => 'name ASC', :source => :user, :conditions => { "#{Membership.table_name}.role" => Role[:administrator] }
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
    self.children.each do |child_group|
      return true if child_group == group
      return true if child_group.has_child?(group)
    end
    return false
  end
  
  def is_child_of?(group)
    if parent
      return true if parent == group
      return true if parent.is_child_of?(group)
    end
    return false
  end
  
  def has_moderator?(user)
    self.moderators.include?(user)
  end
  
  def has_member?(user, with_children = false)
    return true if self.users.include?(user)
    if with_children
      self.children.each do |child_group|
        return true if child_group.has_member?(user, with_children)
      end
    end
    return false
  end
end