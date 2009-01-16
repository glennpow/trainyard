class ArticleType < ActiveEnumeration::Base
  has_enumerated :site, :name => I18n.t('content.article_types.site')
  has_enumerated :news, :name => I18n.t('content.article_types.news')
  has_enumerated :summary, :name => I18n.t('content.article_types.summary')
  has_enumerated :blog, :name => I18n.t('content.blog')
end
