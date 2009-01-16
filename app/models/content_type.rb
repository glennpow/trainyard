class ContentType < ActiveEnumeration::Base
  has_enumerated :mov, :name => I18n.t('content.content_types.quicktime'), :mime => 'video/quicktime', :extension => 'mov'
  has_enumerated :swf, :name => I18n.t('content.content_types.flash'), :mime => 'application/x-shockwave-flash', :extension => 'swf'
  has_enumerated :wmv, :name => I18n.t('content.content_types.windows'), :mime => 'video/x-ms-wmv', :extension => 'wmv'
end
