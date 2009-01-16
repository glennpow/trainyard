class AddressType < ActiveEnumeration::Base
  has_enumerated :billing, :name => I18n.t('contacts.address_types.billing')
  has_enumerated :shipping, :name => I18n.t('contacts.address_types.shipping')
  has_enumerated :po_box, :name => I18n.t('contacts.address_types.po_box')
end
