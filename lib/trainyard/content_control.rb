module Trainyard
  module ContentControl
    def page_title
      @page_title ||= ''
    end
    
    def page_actions
      @page_actions ||= []
    end
    
    def current_blog
      @current_blog ||= Blog.find_by_name(Configuration.default_blog)
    end
    
    def is_commentable?(resource)
      !resource.nil? && (!resource.respond_to?(:commentable?) || resource.commentable?)
    end
    
    def is_reviewable?(resource)
      !resource.nil? && (!resource.respond_to?(:reviewable?) || resource.reviewable?)
    end
    
    def is_taggable?(resource)
      !resource.nil? && (!resource.respond_to?(:taggable?) || resource.taggable?)
    end
    
    def verify_human(resource)
      resource.verified_human = verify_recaptcha(resource)
    end
  
    def self.included(base)
      base.send :helper_method, :page_title, :page_actions, :current_blog, :is_commentable?, :is_reviewable?, :is_taggable? if base.respond_to? :helper_method
    end
  end
end

ActionController::Base.send(:include, Trainyard::ContentControl) if defined?(ActionController::Base)