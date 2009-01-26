class UrlType < ActiveEnumeration::Base
  has_enumerated :business, :translate_key => 'contacts.url_types.business'
  has_enumerated :personal, :translate_key => 'contacts.url_types.personal'
end
