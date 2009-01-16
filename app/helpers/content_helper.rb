module ContentHelper
  def comment_author(comment)
    comment.user.nil? ? h(comment.user_name) : link_to_user(comment.user)
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
    when ContentType[:mov] # Quicktime Video
      capture do
        render :partial => 'medias/video_mov', :locals => locals
      end
    when ContentType[:swf] # Flash Video
      capture do
        render :partial => 'medias/video_swf', :locals => locals
      end
    when ContentType[:wmv] # Windows Video
      capture do
        render :partial => 'medias/video_wmv', :locals => locals
      end
    end
  end

  def message_user(message, mailbox)
    content_tag(message.read || mailbox != :inbox ? :span : :strong, h((mailbox == :inbox ? message.from_user.name : message.to_user.name)))
  end
  
  def message_subject(message, mailbox)
    content_tag(message.read || mailbox != :inbox ? :span : :strong, h(message.subject))
  end

  def may_review?(reviewable)
    logged_in? && Review.may_review?(reviewable, current_user)
  end
  
  def render_rating(review_or_reviewable, options = {})
    max_rating = options[:max_rating] || 5
    
    case review_or_reviewable
    when Review
      rating = review_or_reviewable.rating
      locals = {
        :path => nil,
        :rating => rating,
        :max_rating => max_rating,
        :hide_info => true
      }
    else
      reviewable = review_or_reviewable
      rating = Review.rating_for(reviewable)
      count = reviewable.reviews.count
      locals = {
        :path => options[:path] || if Review.may_review?(reviewable, current_user)
          new_review_path(:reviewable_id => reviewable.id, :reviewable_type => reviewable.class.to_s)
        else
          reviews_path(:reviewable_id => reviewable.id, :reviewable_type => reviewable.class.to_s)
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
  
  def review_descriptor(review)
    content_tag(:div, :class => 'review-descriptor') do
      returning('') do |content|
        content << link_to_user(review.user)
        content << content_tag(:p, review.created_at.to_s(:long))
      end
    end
  end
  
  def review_body(review)
    content_tag(:div, :class => 'review-body') do
      returning('') do |content|
        content << render_rating(review)
        content << render_formatted(review.body)
        content << icon_link_to(:edit, t(:edit), edit_review_path(review)) if is_editor_of?(review)
        content << icon_link_to(:delete, t(:delete), review, :confirm => t(:are_you_sure), :method => :delete) if has_administrator_role?
      end
    end
  end
end