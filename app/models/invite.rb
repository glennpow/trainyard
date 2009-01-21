class Invite < ActiveRecord::Base
  belongs_to :group
  belongs_to :inviter, :class_name => 'User'
  
  validates_presence_of :group, :inviter

  before_create :make_invite_code
    
  
  protected
  
  def make_invite_code
    self.invite_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
end