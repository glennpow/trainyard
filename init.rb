require 'trainyard'

# FIXME - If Rails 2.3 truly has support to load the helpers from engines, then this isn't needed...
if defined?(ActionView::Base)
  Dir[File.dirname(__FILE__) + '/app/helpers/*_helper.rb'].each do |helper_path|
    helper_class = File.basename(helper_path, '.rb').camelize.constantize
    ActionView::Base.send :include, helper_class
  end
end