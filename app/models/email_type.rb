class EmailType < ActiveEnumeration::Base
  has_enumerated :business, :translate_key => 'contacts.email_types.business'
  has_enumerated :personal, :translate_key => 'contacts.email_types.personal'
end
