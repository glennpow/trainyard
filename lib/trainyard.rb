require File.dirname(__FILE__) + '/trainyard/rails_extensions'
require File.dirname(__FILE__) + '/trainyard/configuration'
require File.dirname(__FILE__) + '/trainyard/acts_as_resource'
require File.dirname(__FILE__) + '/trainyard/acts_as_contactable'
require File.dirname(__FILE__) + '/trainyard/acts_as_commentable'
require File.dirname(__FILE__) + '/trainyard/acts_as_reviewable'
require File.dirname(__FILE__) + '/trainyard/acts_as_organizable'
require File.dirname(__FILE__) + '/trainyard/acts_as_organizer'
require File.dirname(__FILE__) + '/trainyard/has_many_articles'
require File.dirname(__FILE__) + '/trainyard/has_one_theme'
require File.dirname(__FILE__) + '/trainyard/authentication_system'
require File.dirname(__FILE__) + '/trainyard/site_system'
require File.dirname(__FILE__) + '/trainyard/resource_system'
require File.dirname(__FILE__) + '/trainyard/content_system'
require File.dirname(__FILE__) + '/trainyard/locale_system'
require File.dirname(__FILE__) + '/trainyard/portlet_system'
require File.dirname(__FILE__) + '/trainyard/theme_system'
require File.dirname(__FILE__) + '/trainyard/content_form_builder'

ActiveRecord::Base.observers << :message_observer << :post_observer << :invite_observer

ActionView::Base.default_form_builder = Trainyard::ContentFormBuilder

Dir[File.dirname(__FILE__) + '/locales/en/*.yml'].each { |path| I18n.load_path.unshift(path) }