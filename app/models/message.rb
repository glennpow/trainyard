class Message < ActiveRecord::Base
  named_scope :unread, :conditions => { :read => false }
  
  belongs_to :to_user, :class_name => 'User'
  belongs_to :from_user, :class_name => 'User'
  
  validates_presence_of :to_user, :message => I18n.t(:user_not_found, :scope => [ :authentication ])
  validates_presence_of :from_user, :subject

  before_save { |message| message.body.strip! }
  
  searches_on :subject, :body
  
  def is_to?(user)
    self.to_user_id == user.id
  end
  
  def is_from?(user)
    self.from_user_id == user.id
  end
end