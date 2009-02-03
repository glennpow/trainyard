module Trainyard
  module PortletSystem
    def is_portlet?(klass = nil)
      !!current_portal(klass)
    end
 
    def current_portal(klass = nil)
      load_current_portal unless defined?(@current_portal)
      return (klass.nil? || @current_portal.is_a?(klass)) ? @current_portal : nil
    end
  
    def current_portal=(portal)
      @current_portal = portal
      if @current_portal
        session[:portal_id] = @current_portal.id
        session[:portal_type] = @current_portal.class.to_s
      end
    end
    
    def load_current_portal
      @current_portal = nil
      if session[:portal_id] && session[:portal_type]
        begin
          @current_portal = session[:portal_type].classify.constantize.find(session[:portal_id])
        rescue
        end
      end
      logger.debug("Application portal: #{@current_portal.inspect}")
      @current_portal
    end
  
    def parse_portal(params = {})
      session[:portal_id] = params[:portal_id]
      session[:portal_type] = params[:portal_type]
      load_current_portal
    end
    
    def reset_portal
      session[:portal_id] = nil
      session[:portal_type] = nil
      load_current_portal
    end

    def self.included(base)
      base.send :helper_method, :is_portlet?, :current_portal if base.respond_to? :helper_method
      base.send :persistent_session_variables, :portal_type, :portal_id if base.respond_to? :persistent_session_variables
    end
  end
end

ActionController::Base.send(:include, Trainyard::PortletSystem) if defined?(ActionController::Base)