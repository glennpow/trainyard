require File.dirname(__FILE__) + '/trainyard/rails_extensions'
require File.dirname(__FILE__) + '/trainyard/configuration'
require File.dirname(__FILE__) + '/trainyard/acts_as_contactable'
require File.dirname(__FILE__) + '/trainyard/acts_as_commentable'
require File.dirname(__FILE__) + '/trainyard/acts_as_reviewable'
require File.dirname(__FILE__) + '/trainyard/acts_as_author'
require File.dirname(__FILE__) + '/trainyard/authentication_system'
require File.dirname(__FILE__) + '/trainyard/content_form_builder'
require File.dirname(__FILE__) + '/trainyard/content_system'
require File.dirname(__FILE__) + '/trainyard/locale_system'
require File.dirname(__FILE__) + '/trainyard/theme_system'

ActiveRecord::Base.observers << :message_observer << :post_observer << :invite_observer

ActionView::Base.default_form_builder = Trainyard::ContentFormBuilder

Dir[File.dirname(__FILE__) + '/locales/en/*.yml'].each { |path| I18n.load_path.unshift(path) }