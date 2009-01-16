class UrlType < ActiveEnumeration::Base
  has_enumerated :business, :name => I18n.t('contacts.url_types.business')
  has_enumerated :personal, :name => I18n.t('contacts.url_types.personal')
end
