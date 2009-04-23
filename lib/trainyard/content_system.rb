module Trainyard
  module ContentSystem
    def log_error(e)
      logger.error("Error: #{e.message}")
      e.backtrace.each { |trace| logger.error("  #{trace}") }
    end

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
      !resource.nil? && (!resource.respond_to?(:reviewable?) || resource.reviewable?)
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
  
    def self.included(base)
      base.send :helper_method, :page_title, :page_actions, :current_blog, :is_commentable?, :is_reviewable? if base.respond_to? :helper_method
    end
  end
end

ActionController::Base.send(:include, Trainyard::ContentSystem) if defined?(ActionController::Base)