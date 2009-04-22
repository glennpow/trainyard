module Trainyard
  module BreadcrumbSystem
    def self.included(base)
      base.extend(ClassMethods)
      base.send :helper_method, :breadcrumbs, :add_breadcrumb if base.respond_to? :helper_method
    end
    
    def breadcrumbs
      @breadcrumbs ||= []
    end

    def add_breadcrumb(name, url = nil)
      url = send(url) if url.is_a?(Symbol)
      self.breadcrumbs << [ name, url ]
    end

    module ClassMethods
      def add_breadcrumb(name, url, options = {})
        before_filter(options) do |controller|
          controller.send(:add_breadcrumb, name, url)
        end
      end
    end
  end
end

ActionController::Base.send(:include, Trainyard::BreadcrumbSystem) if defined?(ActionController::Base)
