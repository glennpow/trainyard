require File.dirname(__FILE__) + '/trainyard/ruby_extensions'
require File.dirname(__FILE__) + '/trainyard/rails_extensions'
require File.dirname(__FILE__) + '/trainyard/configuration'
require File.dirname(__FILE__) + '/trainyard/acts_as_resource'
require File.dirname(__FILE__) + '/trainyard/acts_as_humane'
require File.dirname(__FILE__) + '/trainyard/acts_as_contactable'
require File.dirname(__FILE__) + '/trainyard/acts_as_commentable'
require File.dirname(__FILE__) + '/trainyard/acts_as_reviewable'
require File.dirname(__FILE__) + '/trainyard/acts_as_organizable'
require File.dirname(__FILE__) + '/trainyard/acts_as_organizer'
require File.dirname(__FILE__) + '/trainyard/has_many_articles'
require File.dirname(__FILE__) + '/trainyard/has_one_theme'
require File.dirname(__FILE__) + '/trainyard/authentication_control'
require File.dirname(__FILE__) + '/trainyard/site_control'
require File.dirname(__FILE__) + '/trainyard/resource_control'
require File.dirname(__FILE__) + '/trainyard/content_control'
require File.dirname(__FILE__) + '/trainyard/locale_control'
require File.dirname(__FILE__) + '/trainyard/breadcrumb_control'
require File.dirname(__FILE__) + '/trainyard/portlet_control'
require File.dirname(__FILE__) + '/trainyard/theme_control'
require File.dirname(__FILE__) + '/trainyard/content_form_builder'

ActiveRecord::Base.observers << :message_observer << :post_observer << :invite_observer

ActionView::Base.default_form_builder = Trainyard::ContentFormBuilder

Dir[File.dirname(__FILE__) + '/locales/en/*.yml'].each { |path| I18n.load_path.unshift(path) }