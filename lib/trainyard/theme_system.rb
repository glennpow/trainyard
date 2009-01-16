module Trainyard
  module ThemeSystem
    def current_theme
      if @current_theme.nil?
        @current_theme = Theme.find(params[:theme_id]) if params[:theme_id]
        @current_theme ||= self.controller_theme if self.respond_to?(:controller_theme)
        @current_theme ||= Theme.find_by_name(Configuration.default_theme_name) || Theme.first
        logger.debug("Application theme: #{@current_theme.name}") if @current_theme
      end
      @current_theme
    end

    def self.included(base)
      base.send :helper_method, :current_theme if base.respond_to? :helper_method
    end
  end
end

ActionController::Base.send(:include, Trainyard::ThemeSystem) if defined?(ActionController::Base)