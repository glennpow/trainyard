class UserSession < Authlogic::Session::Base
  after_create :create_user_session
  
  def create_user_session
    self.user.create_session(self.controller.session)
  end
end