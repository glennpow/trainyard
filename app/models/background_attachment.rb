class BackgroundAttachment < ActiveEnumeration::Base
  has_enumerated :scroll, :translate_key => 'themes.scroll'
  has_enumerated :fixed, :translate_key => 'themes.fixed'
end
