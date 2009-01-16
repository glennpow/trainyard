class MessageObserver < ActiveRecord::Observer
  def after_create(message)
    Mailer.deliver_generic_email(:user => message.to_user,
      :subject => I18n.t(:message_from_object, :scope => [ :content ], :object => h(message.from_user.name)),
      :body => "#{h(message.subject)}\n\n#{h(message.body)}\n\n#{Mailer.url_for_path('messages/%d' % message.id)}")
  end
end
