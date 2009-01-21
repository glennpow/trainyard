class Action < ActiveEnumeration::Base
  has_enumerated :view, :name => I18n.t('authentication.actions.view')
  has_enumerated :edit, :name => I18n.t('authentication.actions.edit')
end