class EmailType < ActiveEnumeration::Base
  has_enumerated :business, :name => I18n.t('contacts.email_types.business')
  has_enumerated :personal, :name => I18n.t('contacts.email_types.personal')
end
