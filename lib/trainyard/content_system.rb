module Trainyard
  module ContentSystem
    def current_blog
      @current_blog ||= Blog.find_by_name(Configuration.default_blog)
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
        @page_article = detect_by_locale(Article.all(:conditions => { :groupable_type => 'Page', :groupable_id => page.id }))
      end
    end
  
    def self.included(base)
      base.send :helper_method, :current_blog if base.respond_to? :helper_method
      base.send :before_filter, :load_page_article if base.respond_to? :before_filter
    end
  end
end

ActionController::Base.send(:include, Trainyard::ContentSystem) if defined?(ActionController::Base)