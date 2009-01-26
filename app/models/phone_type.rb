class PhoneType < ActiveEnumeration::Base
  has_enumerated :business, :translate_key => 'contacts.phone_types.business'
  has_enumerated :fax, :translate_key => 'contacts.phone_types.fax'
  has_enumerated :mobile, :translate_key => 'contacts.phone_types.mobile'
  has_enumerated :personal, :translate_key => 'contacts.phone_types.personal'
end
