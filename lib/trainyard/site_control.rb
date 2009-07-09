module Trainyard
  module SiteControl
    def self.included(base)
      base.send :helper_method, :current_site, :site_name, :site_email, :site_email_host, :is_localhost? if base.respond_to? :helper_method
      base.send :before_filter, :default_page_actions if base.respond_to? :before_filter
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

    def default_page_actions
      case action_name
      when 'new', 'edit'
        back_action = @template.link_to_back(t(:cancel)) unless Configuration.hide_cancel_action
      else
        back_action = @template.link_to_back unless Configuration.hide_back_action
      end
      # TODO - find out if/why this before_filter is getting called twice...
      page_actions.unshift(back_action) unless back_action.nil? || page_actions.include?(back_action)
    end
  end
end

ActionController::Base.send(:include, Trainyard::SiteControl) if defined?(ActionController::Base)