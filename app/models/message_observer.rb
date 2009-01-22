class MessageObserver < ActiveRecord::Observer
  def after_create(message)
    Mailer.deliver_generic_email(:user => message.to_user,
      :subject => I18n.t(:message_from_object, :scope => [ :content ], :object => h(message.from_user.name)),
      :body => Proc.new { |template| "#{h(message.subject)}\n\n#{h(message.body)}\n\n#{template.send(:message_path, message)}" }
    )
  end
end
