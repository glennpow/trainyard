class InviteObserver < ActiveRecord::Observer
  def after_create(invite)
    url = Mailer.url_for_path("groups/#{invite.group_id}/invitation/#{invite.invite_code}");
    user = User.find_by_email(invite.email)
    if user.nil?
      Mailer.deliver_generic_email(
        :email => invite.email,
        :subject => I18n.t(:member_invite, :scope => [ :authentication, :invites, :invitation ], :group => invite.group.name),
        :body => I18n.t(:email_body_member_invite, :scope => [ :authentication, :invites, :invitation ], :group => invite.group.name, :url => url))
    else
      message = Message.new
      message.from_user = invite.from_user
      message.to_user = user
      message.subject = I18n.t(:member_invite, :scope => [ :authentication, :invites, :invitation ], :group => invite.group.name)
      message.body = I18n.t(:email_body_member_invite, :scope => [ :authentication, :invites, :invitation ], :group => invite.group.name, :url => url)
      message.save
    end
  end
end
