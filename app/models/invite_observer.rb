class InviteObserver < ActiveRecord::Observer
  def after_create(invite)
    user = User.find_by_email(invite.email)
    if user.nil?
      Mailer.deliver_generic_email(
        :email => invite.email,
        :subject => I18n.t(:member_invite, :scope => [ :authentication, :invites, :invitation ], :group => invite.group.name),
        :body => Proc.new { |template| I18n.t(:email_body_member_invite, :scope => [ :authentication, :invites, :invitation ], :group => invite.group.name,
          :url => template.send(:group_invitation_path, invite.group, invite.invite_code)) }
      )
    else
      message = Message.new
      message.from_user = invite.from_user
      message.to_user = user
      message.subject = I18n.t(:member_invite, :scope => [ :authentication, :invites, :invitation ], :group => invite.group.name)
      message.body = I18n.t(:email_body_member_invite, :scope => [ :authentication, :invites, :invitation ], :group => invite.group.name,
        :url => "groups/#{invite.group_id}/invitation/#{invite.invite_code}")
      message.save
    end
  end
end
