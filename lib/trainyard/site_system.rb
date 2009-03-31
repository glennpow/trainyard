module Trainyard
  module SiteSystem
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

    def self.included(base)
      base.send :helper_method, :current_site, :site_name, :site_email, :site_email_host if base.respond_to? :helper_method
    end
  end
end

ActionController::Base.send(:include, Trainyard::SiteSystem) if defined?(ActionController::Base)