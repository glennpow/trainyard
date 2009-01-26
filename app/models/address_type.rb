class AddressType < ActiveEnumeration::Base
  has_enumerated :billing, :translate_key => 'contacts.address_types.billing'
  has_enumerated :shipping, :translate_key => 'contacts.address_types.shipping'
  has_enumerated :po_box, :translate_key => 'contacts.address_types.po_box'
end
