class User < ActiveRecord::Base
  acts_as_authentic
  acts_as_author
  acts_as_contactable

  has_and_belongs_to_many :groups
  has_many :moderated_groups, :class_name => 'Group', :foreign_key => :moderator_id
  has_and_belongs_to_many :roles
  has_attached_file :image, Configuration.default_image_options
  has_one :user_config, :dependent => :destroy

  validates_attachment_size :image, Configuration.default_image_size_options
  
  has_accessible :user_config

  searches_on :login, :name
 
  after_create :notify_create
  before_save :check_name
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :name, :email, :password, :password_confirmation, :time_zone, :image, :user_config

  def confirm!
    self.update_attribute(:confirmed, true)
    UserMailer.deliver_confirmation(self)
  end
  
  def confirmed?
    self.confirmed
  end
 
  def active?
    self.active
  end
  
  def forgot_password!
    self.reset_perishable_token!
    UserMailer.deliver_forgot_password(self)
  end
    
  def create_session(session)
    session[:locale] = self.locale.code
  end
  
  def name
    super.blank? ? self.login : super
  end

  def self.admin
    self.first(:include => :roles, :conditions => [ "#{Role.table_name}.name = ?", Configuration.admin_role_name ])
  end

  def self.admins
    self.all(:include => :roles, :conditions => [ "#{Role.table_name}.name = ?", Configuration.admin_role_name ])
  end
  
  def has_role?(role)
    self.roles.find_by_name(role) ? true : false
  end
  
  def has_administrator_role?
    has_role?(Configuration.admin_role_name)
  end
  
  def has_editor_role?
    has_role?(Configuration.editor_role_name)
  end
  
  def give_editor_role!
    self.roles << Role.find_by_name(Configuration.editor_role_name) unless self.has_editor_role?
  end
  
  def groups_with_moderated
    (self.moderated_groups + self.groups).uniq
  end
  
  def is_moderator_of?(resource)
    return false if resource.nil?
    return true if has_administrator_role?
    if resource.respond_to?(:moderator)
      resource.moderator == self
    elsif resource.respond_to?(:moderators)
      resource.moderators.include?(self)
    elsif resource.respond_to?(:group)
      self.is_moderator_of?(resource.group)
    end
  end
  
  def is_member_of?(resource)
    return false if resource.nil?
    return true if has_administrator_role?
    return true if is_moderator_of?(resource)
    if resource.is_a?(Group)
      resource.has_member?(self)
    elsif resource.respond_to?(:group)
      resource.group.has_member?(self)
    end
  end
  
  def is_editor_of?(resource)
    return false if resource.nil?
    return true if has_administrator_role?
    if resource.respond_to?(:user)
      resource.user == self
    else
      is_member_of?(resource) && has_editor_role?
    end
  end
  
  def memberships(klass)
    if klass.respond_to?(:find_by_group_id)
      self.groups.map { |group| klass.find_by_group_id(group.id) }.compact
    else
      []
    end
  end
  
  def self.default_user_config
    UserConfig.new(Configuration.default_user_config)
  end
 
  
  protected
  
  def notify_create
    UserMailer.deliver_signup_notification(self)
  end

  def check_name
    self.name = self.login if self.name.blank?
  end
end
