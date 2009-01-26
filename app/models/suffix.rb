class Suffix < ActiveEnumeration::Base
  has_enumerated :ii, :translate_key => 'contacts.suffixes.ii'
  has_enumerated :iii, :translate_key => 'contacts.suffixes.iii'
  has_enumerated :iv, :translate_key => 'contacts.suffixes.iv'
  has_enumerated :jr, :translate_key => 'contacts.suffixes.jr'
  has_enumerated :phd, :translate_key => 'contacts.suffixes.phd'
  has_enumerated :sr, :translate_key => 'contacts.suffixes.sr'
end
