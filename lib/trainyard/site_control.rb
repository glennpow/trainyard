module Trainyard
  module SiteControl
    def self.included(base)
      base.send :helper_method, :current_site, :site_name, :site_email, :site_email_host, :is_localhost?,
        :default_back_action if base.respond_to? :helper_method
      base.send :before_filter, :add_default_page_actions if base.respond_to? :before_filter
    end

    def current_site
      return @current_site if defined?(@current_site)
      @current_site = Configuration.current_site(request)
      logger.debug "Application domain: #{request.domain} (#{@current_site[:name]})"
      @current_site
    end

    def site_name
      current_site[:name]
    end

    def site_email
      current_site[:email]
    end
  
    def site_email_host
      current_site[:email_host]
    end

    def is_localhost?
      request.domain == 'localhost'
    end
    
    def default_back_action
      return @default_back_action if defined?(@default_back_action)
      case action_name
      when 'new', 'edit'
        @default_back_action = @template.link_to_back(t(:cancel)) unless Configuration.hide_cancel_action
      else
        @default_back_action = @template.link_to_back unless Configuration.hide_back_action
      end
    end

    def add_default_page_actions
      page_actions.unshift(default_back_action) unless default_back_action.nil? || page_actions.include?(default_back_action)
    end
    
    def remove_default_page_actions
      page_actions.delete(default_back_action) if default_back_action
    end
  end
end

ActionController::Base.send(:include, Trainyard::SiteControl) if defined?(ActionController::Base)