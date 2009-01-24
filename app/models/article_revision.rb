class ArticleRevision < ActiveRecord::Base
  cattr_accessor :non_revisioned_columns

  belongs_to :article
  belongs_to :user
  
  validates_presence_of :article, :user
  
  searches_on :name, :body
  
  self.non_revisioned_columns = [ :id, :article_id, :revision, :created_at ]
  
  def group
    self.article.group
  end
  
  def self.revisioned_columns
    self.columns.map { |column| column.name.to_sym }.select { |name| !self.non_revisioned_columns.include?(name) }
  end
  
  def revisioned_attributes
    self.attributes.reject { |key, value| self.class.non_revisioned_columns.include?(key.to_sym) }
  end
  
  def revert_page_to!
    self.article.revert_to!(self)
  end
end
