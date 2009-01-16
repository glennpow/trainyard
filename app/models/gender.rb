class Gender < ActiveEnumeration::Base
  has_enumerated :male, :name => I18n.t('contacts.genders.male')
  has_enumerated :female, :name => I18n.t('contacts.genders.female')
end
