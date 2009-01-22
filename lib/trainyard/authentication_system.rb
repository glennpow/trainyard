module Trainyard
  module AuthenticationSystem
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
  
    def logged_in?
      !!current_user
    end

    def login_required
      access_denied unless current_user
    end

    def not_logged_in_required
      if current_user
        store_location
        redirect_to account_url
        return false
      end
    end
    
    def check_condition(condition)
      unless condition
        if logged_in?
          permission_denied
        else
          store_referer
          access_denied
        end
      end
    end

    def has_role?(role, group = nil)
      logged_in? && current_user.has_role?(role, group)
    end
    
    def check_role(role, group = nil)
      check_condition(has_role?(role, group))
    end

    def has_administrator_role?(group = nil)
      logged_in? && current_user.has_administrator_role?(group)
    end

    def check_administrator_role(group = nil)
      check_condition(has_administrator_role?(group))
    end

    def is_moderator_of?(resource)
      logged_in? && current_user.is_moderator_of?(resource)
    end
    
    def check_moderator(resource)
      check_condition(is_moderator_of?(resource))
    end

    def is_member_of?(resource)
      logged_in? && current_user.is_member_of?(resource)
    end
    
    def check_member(resource)
      check_condition(is_member_of?(resource))
    end
    
    def has_permission?(action, resource)
      logged_in? && current_user.permitted?(action, resource)
    end
    
    def check_permission(action, resource)
      check_condition(has_permission?(action, resource))
    end
  
    def is_editor_of?(resource)
      logged_in? && current_user.is_editor_of?(resource)
    end
    
    def check_editor(resource)
      check_condition(is_editor_of?(resource))
    end
  
    def is_viewer_of?(resource)
      logged_in? && current_user.is_viewer_of?(resource)
    end
    
    def check_viewer(resource)
      check_condition(is_viewer_of?(resource))
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def store_back
      session[:return_to] = request.env["HTTP_REFERER"]
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
   
    def store_referer
      session[:refer_to] = request.env["HTTP_REFERER"]
    end

    def redirect_to_referer_or_default(default)
      redirect_to(session[:refer_to] || default)
      session[:refer_to] = nil
    end

    def access_denied
      respond_to do |format|
        format.html do
          store_location
          flash[:error] = t(:access_denied, :scope => [ :authentication ])
          redirect_to new_user_session_url
        end
        format.any(:json, :xml) do
          request_http_basic_authentication 'Web Password'
        end
      end
      return false
    end

    def permission_denied      
      respond_to do |format|
        format.html do
          domain_name = "http://#{Configuration.application_domain}"
          http_referer = session[:refer_to]
          if http_referer.nil?
            store_referer
            http_referer = (session[:refer_to] || domain_name)
          end
          flash[:error] = t(:permission_denied, :scope => [ :authentication ])
          if http_referer[0..(domain_name.length - 1)] != domain_name  
            session[:refer_to] = nil
            redirect_to root_path
          else
            redirect_to_referer_or_default root_path
          end
        end
        format.xml do
          headers["Status"] = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => t(:permission_denied, :scope => [ :authentication ]), :status => '401 Unauthorized'
        end
      end
      return false
    end

    def self.included(base)
      base.send :filter_parameter_logging, :password, :password_confirmation if base.respond_to? :filter_parameter_logging
      base.send :helper_method, :current_user_session, :current_user, :logged_in?,
        :has_role?, :has_administrator_role?, :user_role, :is_moderator_of?, :is_editor_of? if base.respond_to? :helper_method
    end
  end
end

ActionController::Base.send(:include, Trainyard::AuthenticationSystem) if defined?(ActionController::Base)