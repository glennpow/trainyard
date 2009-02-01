class Article < ActiveRecord::Base
  acts_as_resource
  acts_as_commentable
  acts_as_reviewable
  
  belongs_to :resource, :polymorphic => true
  belongs_to :user
  has_many_articles
  has_many :article_revisions, :order => 'revision ASC', :dependent => :destroy do
    def earliest
      @earliest_article_revision ||= find(:first)
    end

    def latest
      @latest_article_revision ||= find(:first, :order => 'revision DESC')
    end
  end
  has_many :authors, :through => :article_revisions, :source => :user, :uniq => true
  belongs_to :locale
  has_many :medias, :as => :resource, :order => 'created_at ASC', :dependent => :destroy
  
  validates_presence_of :resource, :user, :name, :body
  
  searches_on :name, :body
  
  alias_method :author, :user
  
  def group_with_resource
    group_without_resource || self.resource.group
  end
  alias_method_chain :group, :resource
  
  def locale_name
    self.locale.name if self.locale
  end
  
  def next_revision
    return 1 if new_record?
    (article_revisions.calculate(:max, :revision) || 0) + 1
  end
  
  def self.revisioned_columns
    ArticleRevision.revisioned_columns
  end
      
  def revisioned_attributes
    self.attributes.reject { |key, value| !Article.revisioned_columns.include?(key.to_sym) }
  end
  
  def save_revision?
    self.revisionable? && self.changed?
  end

  def save_with_revision
    self.save_with_revision!
    true
  rescue
    false
  end
  alias_method_chain :save, :revision

  def save_with_revision!
    if save_revision = self.save_revision?
      self.revision = self.next_revision
    end
    self.save_without_revision!
    if save_revision
      article_revision = ArticleRevision.new
      Article.clone_revision(self, article_revision)
      article_revision.revision = self.revision
      article_revision.article_id = self.id
      article_revision.save!
    end
  end
  alias_method_chain :save!, :revision
  
  def revert_to!(revision_or_article_revision)
    Article.transaction do
      article_revision = case revision_or_article_revision
      when Fixnum, String
        ArticleRevision.first(:conditions => { :article_id => self, :revision => revision_or_article_revision.to_i })
      when ArticleRevision
        revision_or_article_revision.article_id == self.id ? revision_or_article_revision : nil
      else
        nil
      end
      if article_revision
        Article.clone_revision(article_revision, self)
        self.revision = article_revision.revision
        self.save_without_revision
      else
        false
      end
    end
  end
  
  def revisionable_articles?
    self.revisionable?
  end
    
  def self.clone_revision(src, dst)
    dst.attributes=(src.revisioned_attributes)
  end

  def self.first_by_resource(resource)
    self.first(:conditions => { :resource_type => resource.class.to_s, :resource_id => resource.id })
  end
  
  def self.all_by_resource(resource)
    self.all(:conditions => { :resource_type => resource.class.to_s, :resource_id => resource.id })
  end
end
