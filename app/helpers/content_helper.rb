module ContentHelper
  def head(content)
    content_for(:head) { content }
  end

  def javascript(*files)
    options = files.extract_options!
    files.each do |file|
      unless (@javascript_files ||= []).include?(file)
        @javascript_files << file
        content_for(:head) { javascript_include_tag(file, options) }
      end
    end
  end
  
  def stylesheet(*files)
    options = files.extract_options!
    files.each do |file|
      unless (@stylesheet_files ||= []).include?(file)
        @stylesheet_files << file
        content_for(:head) { stylesheet_link_tag(file, options) }
      end
    end
  end
  
  def title(title = nil)
    page_title.replace(title || '')
  end
  
  def page_action(action)
    page_actions << action unless page_actions.include?(action)
  end
  
  def random_id(length = 8)
    chars = ("a".."z").to_a + ("A".."Z").to_a + [ "_" ]
    id = chars[rand(chars.size - 1)]
    chars += ("0".."9").to_a
    2.upto(length) { |i| id << chars[rand(chars.size - 1)] }
    return id
  end
  
  def url_escape(string)
    URI.escape(CGI.escape(string),'.')
  end
  
  def check_param(keys, default = nil)
    hash = params
    [ keys ].flatten.each do |key|
      hash = hash[key]
      break if hash.nil?
    end
    hash.nil? ? default : hash
  end

  def auto_format(text)
    textilize(auto_link(text))
  end

  def strip_links(content_or_options_with_block = nil, &block)
    if block_given?
      content = block_called_from_erb?(block) ? capture(&block) : yield
    else
      content = content_or_options_with_block
    end
    content.gsub!(/href=['"][^'"]+?['"]/, "href='#'")
    (block_given? && block_called_from_erb?(block)) ? concat(content) : content
  end

  def render_breadcrumbs(options = {})
    options[:class] = merge_classes(options[:class], 'breadcrumbs')
    render_bar_list(breadcrumbs.map { |name, url| link_to_unless_current(name, url) }, :class => options[:class]) unless breadcrumbs.blank?
  end
  
  def yes_no(value)
    t(value.true? ? :yes : :no)
  end

  def link_to_resource(resource, options = {}, html_options = {})
    if resource
      label_method = options.delete(:label_method) || :name
      label = options.delete(:label) || h(resource.send(label_method))
      link_to(label, resource, options, html_options)
    else
      options[:nil_label] || "-"
    end
  end

  def link_to_text_style_hint
    t(:text_style_hint, :scope => [ :content ],
      :link => link_to(Configuration.text_style_hint_label, Configuration.text_style_hint_link, :target => "_blank"))
  end
  
  def render_article(article, options = {})
    article_class = [ options[:class], 'article' ].join(' ')
    render :partial => 'articles/show', :locals => { :article => article, :article_class => article_class }
  end
  
  def render_articles(resource, options = {})
    if resource.articles.any? || is_editor_of?(resource)
      returning('') do |content|
        resource_name = ActionController::RecordIdentifier.singular_class_name(resource)
        unless options[:noheading]
          content << render_heading(named_anchor('articles', tp(:article, :scope => [ :content ])), :actions => [
            is_editor_of?(resource) ? link_to(t(:view_all), send(:"#{resource_name}_articles_path", resource)) : nil,
          ])
        end
        for_each_by_locale(resource.articles) do |article|
          content << render_article(article, options)
        end
      end
    end
  end
  
  def for_page_content(options = {}, &block)
    path = options[:route] ? "/#{controller_name}/#{action_name}" : request.path
    page = Page.find_by_permalink(path)
    article = first_by_locale(Article.all_by_resource(page), :include_default_language => true, :include_default_language => true) if page
    block.call(article) if article
  end

  def render_media(media, options = {})
    locals = {
      :src => media.source,
      :width => options[:width] || media.width,
      :height => options[:height] || media.height,
      :autoplay => options[:autoplay] || true,
      :looped => options[:loop] ||= false,
      :controller => options[:controller] || true
    }
    case media.content_type
    when ContentType.mov
      render :partial => 'medias/video_mov', :locals => locals
    when ContentType.swf
      render :partial => 'medias/video_swf', :locals => locals
    when ContentType.wmv
      render :partial => 'medias/video_wmv', :locals => locals
    end
  end

  def message_user(message, mailbox)
    content_tag(message.read || mailbox != :inbox ? :span : :strong, h((mailbox == :inbox ? message.from_user.name : message.to_user.name)))
  end
  
  def message_subject(message, mailbox)
    content_tag(message.read || mailbox != :inbox ? :span : :strong, h(message.subject))
  end
  
  def comment_author(comment)
    comment.user.nil? ? h(comment.user_name) : link_to_user(comment.user)
  end

  def may_comment?(resource)
    true
  end

  def render_comments(resource, options = {})
    returning('') do |content|
      if is_commentable?(resource)
        comments_indexer = create_indexer(Comment) do |options|
          options[:order] = 'created_at ASC'
          options[:no_table] = true
          options[:per_page] = 10

          options[:conditions] = [ "resource_type = ? AND resource_id = ?", resource.class.to_s, resource.id ]
          options[:paginate] = { :params => { :controller => 'comments', :action => 'list', :resource_id => resource.id } }
        end
        resource_name = ActionController::RecordIdentifier.singular_class_name(resource)
        content << render_heading(named_anchor('comments', tp(:comment, :scope => [ :content ])), :actions => [
          comments_indexer.collection.total_entries > comments_indexer.collection.count ?
            link_to(t(:view_all), send(:"#{resource_name}_comments_path", resource)) : nil,
          link_to(t(:post_comment, :scope => [ :content ]), send(:"new_#{resource_name}_comment_path", resource))
        ])
        content << render_indexer(comments_indexer, options)
      end
    end
  end

  def may_review?(resource)
    logged_in? && Review.may_review?(resource, current_user)
  end
  
  def render_rating(review_or_resource, options = {})
    max_rating = options[:max_rating] || 5
    
    case review_or_resource
    when Review
      rating = review_or_resource.rating
      locals = {
        :path => nil,
        :rating => rating,
        :max_rating => max_rating,
        :hide_info => true
      }
    else
      resource = review_or_resource
      rating = Review.rating_for(resource)
      count = resource.reviews.count
      locals = {
        :path => options[:path] || if Review.may_review?(resource, current_user)
          new_review_path(:resource_id => resource.id, :resource_type => resource.class.to_s)
        else
          reviews_path(:resource_id => resource.id, :resource_type => resource.class.to_s)
        end,
        :rating => rating,
        :max_rating => max_rating,
        :label => options[:label] || (count.zero? ? t(:reviews, :scope => [ :content ], :count => count) :
          "%.1f / #{max_rating} (#{t(:reviews, :scope => [ :content ], :count => count)})" % rating),
        :info => options[:info] || t(:reviews, :scope => [ :content ], :count => count),
        :count => count,
        :hide_info => options[:hide_info] != false
      }
    end
    
    capture do
      render :partial => 'layout/rating', :locals => locals
    end
  end
  
  def render_reviews(resource, options = {})
    returning('') do |content|
      if is_reviewable?(resource)
        reviews_indexer = create_indexer(Review) do |options|
          options[:order] = 'created_at ASC'
          options[:no_table] = true
          options[:per_page] = 5

          options[:conditions] = [ "resource_type = ? AND resource_id = ?", resource.class.to_s, resource.id ]
          options[:paginate] = { :params => { :controller => 'reviews', :action => 'list', :resource_id => resource.id } }
        end
        resource_name = ActionController::RecordIdentifier.singular_class_name(resource)
        content << render_heading(named_anchor('reviews', tp(:review, :scope => [ :content ])), :actions => [
          reviews_indexer.collection.total_entries > reviews_indexer.collection.count ? link_to(t(:view_all), send(:"#{resource_name}_reviews_path", resource)) : nil,
          may_review?(resource) ? link_to(t(:post_review, :scope => [ :content ]), send(:"new_#{resource_name}_review_path", resource)) : nil
        ])
        content << render_indexer(reviews_indexer, options)
      end
    end
  end
  
  def render_watching(resource, options = {})
    if logged_in? && current_user.is_watching?(resource)
      if options[:type] == :button
        button_to(t(:watching, :scope => [ :content ]), user_watchings_path(current_user, :resource_type => resource.class.to_s))
      else
        icon_link_to(:check, t(:watching, :scope => [ :content ]), user_watchings_path(current_user, :resource_type => resource.class.to_s))
      end
    else
      if options[:type] == :button
        button_to(t(:watch, :scope => [ :content ]), watchings_path(:resource_type => resource.class.to_s, :resource_id => resource.id), :method => :post)
      else
        icon_link_to(:add, t(:watch, :scope => [ :content ]), watchings_path(:resource_type => resource.class.to_s, :resource_id => resource.id), :method => :post)
      end
    end
  end

  def render_tags(resource)
    returning('') do |content|
      if is_taggable?(resource)
        content << render_field(named_anchor('tags', tp(:tag, :scope => [ :content ])), resource.tags.map { |tag| "<span class='tag'>#{tag}</span>" }.join(' '))
      end
    end
  end
end