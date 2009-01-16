require 'trainyard'

if defined?(ActionView::Base)
  Dir[File.dirname(__FILE__) + '/app/helpers/*_helper.rb'].each do |helper_path|
    helper_class = File.basename(helper_path, '.rb').camelize.constantize
    ActionView::Base.send :include, helper_class
  end
end