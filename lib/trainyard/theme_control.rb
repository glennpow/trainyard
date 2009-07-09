module Trainyard
  module ThemeControl
    def controller_theme
      return @controller_theme if defined?(@controller_theme)
      @controller_theme = self.respond_to?(:current_portal) && self.current_portal && self.current_portal.respond_to?(:theme) ? self.current_portal.theme : nil
    end
    
    def default_theme
      Theme.first || Theme.new
    end

    def current_theme
      return @current_theme if defined?(@current_theme)
      @current_theme = Theme.find(params[:theme_id]) if params[:theme_id]
      @current_theme ||= self.controller_theme
      unless @current_theme
        application_themeable = ThemeablesTheme.first(:conditions => { :themeable_type => nil, :themeable_id => nil })
        @current_theme = (application_themeable ? application_themeable.theme : nil) || default_theme
      end
      @current_theme.attributes=(params[:theme]) if params[:theme]
      logger.debug("Application theme: #{@current_theme.name}") if @current_theme
      @current_theme
    end

    def self.included(base)
      base.send :helper_method, :default_theme, :current_theme if base.respond_to? :helper_method
    end
  end
end

ActionController::Base.send(:include, Trainyard::ThemeControl) if defined?(ActionController::Base)