class Invite < ActiveRecord::Base
  belongs_to :group
  
  validates_presence_of :group

  before_create :make_invite_code
    
  def make_invite_code
    self.invite_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
end