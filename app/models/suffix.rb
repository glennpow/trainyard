class Suffix < ActiveEnumeration::Base
  has_enumerated :ii, :name => I18n.t('contacts.suffixes.ii')
  has_enumerated :iii, :name => I18n.t('contacts.suffixes.iii')
  has_enumerated :iv, :name => I18n.t('contacts.suffixes.iv')
  has_enumerated :jr, :name => I18n.t('contacts.suffixes.jr')
  has_enumerated :phd, :name => I18n.t('contacts.suffixes.phd')
  has_enumerated :sr, :name => I18n.t('contacts.suffixes.sr')
end
