module ContentHelper
  def head(content)
    content_for(:head) { content }
  end

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end
  
  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end
  
  def title(title = nil)
    page_title.replace(title || '')
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

  def link_to_textile_hint
    t(:text_style_hint, :scope => [ :site_content ],
      :link => link_to("Textile", "http://hobix.com/textile/quick.html", :target => "_blank"))
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

  def render_comments(resource)
    returning('') do |content|
      if is_commentable?(resource)
        resource_name = ActionController::RecordIdentifier.singular_class_name(resource)
        content << render_heading(link_to(tp(:comment, :scope => [ :content ]), send(:"#{resource_name}_comments_path", resource)), :actions => [
          link_to(t(:post_comment, :scope => [ :content ]), send(:"new_#{resource_name}_comment_path", resource))
        ])
        content << render_indexer(@comments_indexer) if @comments_indexer
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
      render :partial => 'theme/rating', :locals => locals
    end
  end
  
  def render_reviews(resource)
    returning('') do |content|
      if is_reviewable?(resource)
        resource_name = ActionController::RecordIdentifier.singular_class_name(resource)
        content << render_heading(link_to(tp(:review, :scope => [ :content ]), send(:"#{resource_name}_reviews_path", resource)), :actions => [
          may_review?(resource) ? link_to(t(:post_review, :scope => [ :content ]), send(:"new_#{resource_name}_review_path", resource)) : nil
        ])
        content << render_indexer(@reviews_indexer) if @reviews_indexer
      end
    end
  end
  
  def render_article(article, options = {})
    article_class = [ options[:class], 'article' ].join(' ')
    render :partial => 'articles/show', :locals => { :article => article, :article_class => article_class }
  end
  
  def for_page_content(options = {}, &block)
    path = options[:route] ? "/#{controller_name}/#{action_name}" : request.path
    page = Page.find_by_permalink(path)
    article = Article.first_by_resource(page) if page
    block.call(article) if article
  end
end