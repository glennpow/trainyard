class BackgroundRepeat < ActiveEnumeration::Base
  has_enumerated :no_repeat, :translate_key => 'themes.no_repeat'
  has_enumerated :repeat, :translate_key => 'themes.repeat'
  has_enumerated :repeat_x, :translate_key => 'themes.repeat_x'
  has_enumerated :repeat_y, :translate_key => 'themes.repeat_y'
end
