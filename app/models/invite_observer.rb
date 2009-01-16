class InviteObserver < ActiveRecord::Observer
  def after_create(invite)
    url = Mailer.url_for_path("groups/#{invite.group.id}/invitation/#{invite.invite_code}");
    user = User.find_by_email(invite.email)
    if user.nil?
      Mailer.deliver_generic_email(
        :email => invite.email,
        :subject => I18n.t(invite.moderator ? :moderator_invite : :member_invite, :scope => [ :authenticate, :invites, :invitation ], :group => invite.group.name),
        :body => I18n.t(invite.moderator ? :email_body_moderator_invite : :email_body_member_invite, :scope => [ :authenticate, :invites, :invitation ], :group => invite.group.name, :url => url))
    else
      message = Message.new
      message.from_user = invite.group.moderator
      message.to_user = user
      message.subject = I18n.t(invite.moderator ? :moderator_invite : :member_invite, :scope => [ :authenticate, :invites, :invitation ], :group => invite.group.name)
      message.body = I18n.t(invite.moderator ? :email_body_moderator_invite : :email_body_member_invite, :scope => [ :authenticate, :invites, :invitation ], :group => invite.group.name, :url => url)
      message.save
    end
  end
end
