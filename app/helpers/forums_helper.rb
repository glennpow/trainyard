module ForumsHelper
  def may_edit_guru_points?(post)
    logged_in? && post.may_edit_guru_points?(current_user)
  end

  def forum_descriptor(forum)
    content_tag(:div, :class => 'forum-descriptor') do
      returning('') do |content|
        content << content_tag(:p, link_to_resource(forum), :class => 'forum-name')
        content << content_tag(:p, h(forum.description), :class => 'forum-description')
      end
    end
  end
  
  def forum_breadcrumbs(forum)
    render_bar_list([
      link_to(tp(:forum, :scope => [ :content ]), forums_path),
      h(forum.name),
    ], :class => 'breadcrumbs')
  end

  def topic_descriptor(topic)
    content_tag(:div, :class => 'topic-descriptor') do
      returning('') do |content|
        content << content_tag(:p, link_to_resource(topic), :class => "topic-name #{topic.sticky ? 'sticky' : ''}")
        content << content_tag(:p, t(:by_author, :scope => [ :content ], :author => link_to_user(topic.user)), :class => 'topic-user')
      end
    end
  end
  
  def topic_breadcrumbs(topic)
    render_bar_list([
      link_to(tp(:forum, :scope => [ :content ]), forums_path),
      link_to_resource(topic.forum),
      h(topic.name),
    ], :class => 'breadcrumbs')
  end
  
  def post_breadcrumbs(post)
    render_bar_list([
      link_to(tp(:forum, :scope => [ :content ]), forums_path),
      link_to_resource(post.forum),
      link_to_resource(post.topic),
      t(:post, :scope => [ :content ]),
    ], :class => 'breadcrumbs')
  end
end