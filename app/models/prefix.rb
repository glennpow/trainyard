class Prefix < ActiveEnumeration::Base
  has_enumerated :dr, :translate_key => 'contacts.prefixes.dr'
  has_enumerated :mr, :translate_key => 'contacts.prefixes.mr'
  has_enumerated :mrs, :translate_key => 'contacts.prefixes.mrs'
  has_enumerated :ms, :translate_key => 'contacts.prefixes.ms'
end
