class PostObserver < ActiveRecord::Observer
  def after_create(post)
    Mailer.deliver_generic_email(:users => post.topic.contributors.reject { |user| user.id == post.user_id },
      :subject => I18n.t(:new_post_for_topic, :scope => [ :content ], :topic => h(post.topic.name)),
      :body => Proc.new { |template| I18n.t(:from, :scope => [ :content ]) + ": " + h(post.user.name) + "\n\n" + template.auto_format(post.body) + "\n\n" + template.send(:post_path, post) }
    )
  end
end
