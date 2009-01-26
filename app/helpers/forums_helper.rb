module ForumsHelper
  def may_edit_guru_points?(post)
    logged_in? && post.may_edit_guru_points?(current_user)
  end

  def forum_descriptor(forum)
    returning('') do |content|
      content_tag(:div, :class => 'forum-descriptor') do
        content << content_tag(:p, link_to(h(forum.name), forum_path(forum)), :class => 'forum-name')
        content << content_tag(:p, h(forum.description), :class => 'forum-description')
      end
    end
  end
  
  def forum_breadcrumbs(forum)
    render_bar_list([
      link_to(tp(:forum, :scope => [ :forums ]), forums_path),
      h(forum.name),
    ], :class => 'breadcrumbs')
  end

  def topic_descriptor(topic)
    returning('') do |content|
      content_tag(:div, :class => 'topic-descriptor') do
        content << content_tag(:p, link_to(h(topic.name), topic_path(topic)), :class => "topic-name #{topic.sticky ? 'sticky' : ''}")
        content << content_tag(:p, t(:by_author, :scope => [ :forums ], :author => link_to_user(topic.user)), :class => 'topic-user')
      end
    end
  end
  
  def topic_breadcrumbs(topic)
    render_bar_list([
      link_to(tp(:forum, :scope => [ :forums ]), forums_path),
      link_to(h(topic.forum.name), forum_path(topic.forum)),
      h(topic.name),
    ], :class => 'breadcrumbs')
  end
  
  def post_breadcrumbs(post)
    render_bar_list([
      link_to(tp(:forum, :scope => [ :forums ]), forums_path),
      link_to(h(post.forum.name), forum_path(post.forum)),
      link_to(h(post.topic.name), topic_path(post.topic)),
      t(:post, :scope => [ :forums ]),
    ], :class => 'breadcrumbs')
  end
end