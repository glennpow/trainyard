class Role < ActiveEnumeration::Base
  has_enumerated :administrator, :name => I18n.t('authentication.roles.administrator')
  has_enumerated :editor, :name => I18n.t('authentication.roles.editor')
  has_enumerated :user, :name => I18n.t('authentication.roles.user')
end