module ForumsHelper
  def may_edit_guru_points?(post)
    logged_in? && post.may_edit_guru_points?(current_user)
  end
  
  def topic_descriptor(topic)
    content_tag(:div, :class => 'topic-descriptor') do
      returning('') do |content|
        content << content_tag(:p, link_to_resource(topic), :class => "topic-name #{topic.sticky ? 'sticky' : ''}")
        content << content_tag(:p, t(:by_author, :scope => [ :content ], :author => link_to_user(topic.user)), :class => 'topic-user')
      end
    end
  end
end