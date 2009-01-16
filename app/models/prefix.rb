class Prefix < ActiveEnumeration::Base
  has_enumerated :dr, :name => I18n.t('contacts.prefixes.dr')
  has_enumerated :mr, :name => I18n.t('contacts.prefixes.mr')
  has_enumerated :mrs, :name => I18n.t('contacts.prefixes.mrs')
  has_enumerated :ms, :name => I18n.t('contacts.prefixes.ms')
end
