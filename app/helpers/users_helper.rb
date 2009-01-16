module UsersHelper
  def link_to_user(user, options = {})
    raise "Invalid user" unless user
    options[:class] ||= 'user-name'
    content_method = options.delete(:content_method) || :name
    content = options.delete(:content) || h(user.send(content_method))
    title_method = options.delete(:title_method) || :name
    options[:title] ||= h(user.send(title_method))
    link_to(content, user_path(user), options)
  end
  
  def image_link_to_user(user, options = {})
    raise "Invalid user" unless user
    image_class = options[:class] || 'user-image'
    options[:class] = ''
    image_style = options.delete(:image_style) || nil
    link_to_user(user, options.merge(:content => image_tag(user.image.url(image_style), :class => image_class)))
  end
end
