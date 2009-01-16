class PhoneType < ActiveEnumeration::Base
  has_enumerated :business, :name => I18n.t('contacts.phone_types.business')
  has_enumerated :fax, :name => I18n.t('contacts.phone_types.fax')
  has_enumerated :mobile, :name => I18n.t('contacts.phone_types.mobile')
  has_enumerated :personal, :name => I18n.t('contacts.phone_types.personal')
end
