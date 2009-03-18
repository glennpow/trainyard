class ArticleType < ActiveEnumeration::Base
  has_enumerated :site, :translate_key => 'site'
  has_enumerated :wiki, :translate_key => 'content.wiki'
  has_enumerated :blog, :translate_key => 'content.blog'
end
