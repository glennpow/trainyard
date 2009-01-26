class ContentType < ActiveEnumeration::Base
  has_enumerated :mov, :translate_key => 'content.content_types.quicktime', :mime => 'video/quicktime', :extension => 'mov'
  has_enumerated :swf, :translate_key => 'content.content_types.flash', :mime => 'application/x-shockwave-flash', :extension => 'swf'
  has_enumerated :wmv, :translate_key => 'content.content_types.windows', :mime => 'video/x-ms-wmv', :extension => 'wmv'
end
