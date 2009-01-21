module Trainyard
  module ContentSystem
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
      !resource.respond_to?(:commentable?) || resource.commentable?
    end
    
    def load_comments(resource)
      if is_commentable?(resource)
        @comments_indexer = create_indexer(Comment) do |options|
          options[:order] = 'created_at ASC'
          options[:no_table] = true
          options[:per_page] = 10

          options[:conditions] = [ "resource_type = ? AND resource_id = ?", resource.class.to_s, resource.id ]
          options[:paginate] = { :params => { :controller => 'comments', :action => 'list', :resource_id => resource.id } }
        end
      end
    end
    
    def is_reviewable?(resource)
      !resource.respond_to?(:reviewable?) || resource.reviewable?
    end
    
    def load_reviews(resource)
      if is_reviewable?(resource)
        @reviews_indexer = create_indexer(Review) do |options|
          options[:order] = 'created_at ASC'
          options[:no_table] = true
          options[:per_page] = 5

          options[:conditions] = [ "resource_type = ? AND resource_id = ?", resource.class.to_s, resource.id ]
          options[:paginate] = { :params => { :controller => 'reviews', :action => 'list', :resource_id => resource.id } }
        end
      end
    end
    
    def load_page_article
      page_name ||= "#{self.action_name}_#{self.controller_name}"
      if case Configuration.local_article_pages
        when true
          true
        when Array
          Configuration.local_article_pages.include?(page_name)
        else
          false
        end
        page = Page.find_by_name(page_name, :select => "id")
        @page_article = first_by_locale(Article.all(:conditions => { :resource_type => 'Page', :resource_id => page.id }))
      end
    end
  
    def self.included(base)
      base.send :helper_method, :page_title, :page_actions, :current_blog, :is_commentable?, :is_reviewable? if base.respond_to? :helper_method
      base.send :before_filter, :load_page_article if base.respond_to? :before_filter
    end
  end
end

ActionController::Base.send(:include, Trainyard::ContentSystem) if defined?(ActionController::Base)