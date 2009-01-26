class Gender < ActiveEnumeration::Base
  has_enumerated :male, :translate_key => 'contacts.genders.male'
  has_enumerated :female, :translate_key => 'contacts.genders.female'
end
