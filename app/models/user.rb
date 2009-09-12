class User < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  acts_as_authentic
  acts_as_contactable if Configuration.contactable_users
  acts_as_organizer

  has_one :persona, :as => :resource, :dependent => :destroy
  accepts_nested_attributes_for :persona, :allow_destroy => true
  has_many :memberships, :order => 'group_id ASC', :dependent => :destroy
  has_many :groups, :through => :memberships, :order => 'name ASC'
  has_many :moderated_groups, :through => :memberships, :source => :group, :conditions => { "#{Membership.table_name}.role" => Role[:administrator] }
  has_many :permissions, :through => :groups
  has_attached_file :image, Configuration.default_image_options
  belongs_to :locale
  has_many :messages, :foreign_key => :to_user_id, :order => 'created_at DESC'
  has_many :sent_messages, :class_name => 'Message', :foreign_key => :from_user_id, :order => 'created_at DESC'
  has_many :posts, :order => 'created_at DESC'
  has_many :friendships, :include => :friend, :order => "#{User.table_name}.name ASC", :dependent => :destroy
  has_many :friends, :through => :friendships
  has_many :requested_friendships, :class_name => 'Friendship', :include => :friend, :order => "#{User.table_name}.name ASC", :conditions => { :friendship_type => FriendshipType[:requested] }
  has_many :requested_friends, :through => :requested_friendships, :source => :friend
  has_many :pending_friendships, :class_name => 'Friendship', :include => :friend, :order => "#{User.table_name}.name ASC", :conditions => { :friendship_type => FriendshipType[:pending] }
  has_many :pending_friends, :through => :pending_friendships, :source => :friend
  has_many :accepted_friendships, :class_name => 'Friendship', :include => :friend, :order => "#{User.table_name}.name ASC", :conditions => { :friendship_type => FriendshipType[:accepted] }
  has_many :accepted_friends, :through => :accepted_friendships, :source => :friend
  has_many :inverse_friendships, :class_name => 'Friendship', :foreign_key => :friend_id, :include => :user, :dependent => :destroy
  has_many :watchings, :dependent => :destroy

  validates_attachment_size :image, Configuration.default_image_size_options
  validates_attachment_content_type :image, :content_type => Configuration.default_image_content_types
  validates_confirmation_of :email, :if => :email_changed?
  validates_presence_of :email_confirmation, :if => :email_changed?

  searches_on :login, :name
 
  before_create :reset_config
  after_create :notify_create
  before_save :check_name
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you don't want your user to change should be added here.
  attr_protected :crypted_password, :password_salt, :persistence_token, :perishable_token, :current_login_at, :confirmed, :active, :posts_count, :guru_points

  def confirm!
    self.update_attribute(:confirmed, true)
    UserMailer.deliver_confirmation(self)
  end
  
  def forgot_password!
    self.reset_perishable_token!
    UserMailer.deliver_forgot_password(self)
  end
    
  def create_session(session)
    session[:locale] = self.locale.code if self.locale
  end
  
  def name
    @name ||= super.blank? ? self.login : super
  end

  def self.administrator
    self.administrators.first
  end

  def self.administrators
    @@administrators ||= Membership.all(:include => :user, :conditions => { :group_id => nil, :role => Role[:administrator] }).map(&:user)
  end
  
  def roles(group = nil)
    Membership.all(:conditions => { :user_id => self.id, :group_id => group }).map(&:role)
  end
  memoize :roles
  
  def has_role?(role, group = nil)
    Membership.count(:conditions => { :user_id => self.id, :role => role, :group_id => group }) > 0
  end
  memoize :has_role?
  
  def has_administrator_role?(group = nil)
    has_role?(Role[:administrator], group)
  end
  
  def has_editor_role?(group = nil)
    has_role?(Role[:editor], group)
  end
  
  def assign_role!(role, group = nil)
    Membership.create(:user_id => self.id, :role => role, :group => group) unless self.has_role?(role, group)
  end
  
  def is_moderator_of?(resource)
    return true if has_administrator_role?
    return false if resource.nil?
    return resource.moderators.include?(self) if resource.respond_to?(:moderators)
    return resource.respond_to?(:group) && resource.group && resource.group.has_moderator?(self)
  end
  memoize :is_moderator_of?
  
  def is_member_of?(resource, with_children = false)
    return true if has_administrator_role?
    return false if resource.nil?
    return resource.respond_to?(:group) && resource.group && resource.group.has_member?(self, with_children)
  end
  # FIXME - This causes calls to fail when with_children = true...
  #memoize :is_member_of?
    
  def permitted?(action, resource)
    Permission.permitted?(self, action, resource)
  end
  
  def is_editor_of?(resource)
    return permitted?(Action.edit, resource)
  end
  
  def is_viewer_of?(resource)
    return permitted?(Action.view, resource)
  end

  def membered(*args)
    ([ args ].flatten).map do |klass|
      klass.all(:include => { :group => :memberships }, :conditions => { "#{Membership.table_name}.user_id" => self })
    end.flatten
  end
  memoize :membered

  def moderated(*args)
    ([ args ].flatten).map do |klass|
      klass.all(:include => { :group => :memberships }, :conditions => { "#{Membership.table_name}.user_id" => self, "#{Membership.table_name}.role" => Role[:administrator] })
    end.flatten
  end
  memoize :moderated
  
  def friendship_with(user)
    Friendship.find_between(self, user)
  end
  
  def watched(klass = nil)
    self.watchings.all(:conditions => klass ? { :resource_type => klass.to_s } : nil).map(&:resource)
  end
  memoize :watched
  
  def is_watching?(resource)
    self.watchings.count(:conditions => { :resource_type => resource.class.to_s, :resource_id => resource.id }) > 0
  end
  memoize :is_watching?
 
  
  protected
  
  def reset_config
    self.attributes=(Configuration.default_user_config)
  end
  
  def notify_create
    UserMailer.deliver_signup_notification(self)
  end

  def check_name
    self.name = self.login if self.name.blank?
  end
end
