class User < ActiveRecord::Base
  acts_as_authentic
  acts_as_contactable if Configuration.contactable_users

  has_one :persona, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships, :order => 'name ASC'
  has_many :moderated_groups, :through => :memberships, :source => :group, :conditions => { "#{Membership.table_name}.role_id" => Role.administrator.id }
  has_many :permissions, :through => :groups
  has_attached_file :image, Configuration.default_image_options
  belongs_to :locale
  has_many :messages, :foreign_key => :to_user_id, :order => 'created_at DESC'
  has_many :sent_messages, :class_name => 'Message', :foreign_key => :from_user_id, :order => 'created_at DESC'
  has_many :posts, :order => 'created_at DESC'
  has_many :watchings, :dependent => :destroy

  validates_attachment_size :image, Configuration.default_image_size_options

  searches_on :login, :name
 
  before_create :reset_config
  after_create :notify_create
  before_save :check_name
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :name, :email, :password, :password_confirmation, :time_zone, :image, :locale_id

  def confirm!
    self.update_attribute(:confirmed, true)
    UserMailer.deliver_confirmation(self)
  end
  
  def forgot_password!
    self.reset_perishable_token!
    UserMailer.deliver_forgot_password(self)
  end
    
  def create_session(session)
    session[:locale] = self.locale.code
  end
  
  def name
    @name ||= super.blank? ? self.login : super
  end

  def self.administrator
    self.administrators.first
  end

  def self.administrators
    @@administrators ||= Membership.all(:include => :user, :conditions => { :group_id => nil, :role_id => Role.administrator.id }).map(&:user)
  end
  
  def roles(group = nil)
    Membership.all(:conditions => { :user_id => self.id, :group_id => group }).map(&:role)
  end
  
  def has_role?(role, group = nil)
    Membership.count(:conditions => { :user_id => self.id, :role_id => role.id, :group_id => group }) > 0
  end
  
  def has_administrator_role?(group = nil)
    has_role?(Role.administrator, group)
  end
  
  def has_editor_role?(group = nil)
    has_role?(Role.editor, group)
  end
  
  def assign_role!(role, group = nil)
    Membership.create(:user_id => self.id, :role_id => role.id, :group_id => group) unless self.has_role?(role, group)
  end
  
  def is_moderator_of?(resource)
    return true if has_administrator_role?
    return false if resource.nil?
    return resource.moderators.include?(self) if resource.respond_to?(:moderators)
    return resource.respond_to?(:group) && resource.group && resource.group.has_moderator?(self)
  end
  
  def is_member_of?(resource, with_child_groups = false)
    return true if has_administrator_role?
    return false if resource.nil?
    return resource.respond_to?(:group) && resource.group && resource.group.has_member?(self, with_child_groups)
  end
    
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

  def moderated(*args)
    ([ args ].flatten).map do |klass|
      klass.all(:include => { :group => :memberships }, :conditions => { "#{Membership.table_name}.user_id" => self, "#{Membership.table_name}.role_id" => Role.administrator.id })
    end.flatten
  end
  
  def identities
    self.has_administrator_role? ? [ I18n.t(:administrator, :scope => [ :authentication, :roles ]) ] : []
  end
  
  def watched(klass = nil)
    self.watchings.all(:conditions => klass ? { :resource_type => klass.to_s } : nil).map(&:resource)
  end
  
  def is_watching?(resource)
    self.watchings.count(:conditions => { :resource_type => resource.class.to_s, :resource_id => resource.id }) > 0
  end
 
  
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
