class Article < ActiveRecord::Base
  belongs_to :groupable, :polymorphic => true
  has_enumeration :article_type
  belongs_to :locale
  has_many :medias, :as => :groupable, :order => 'created_at ASC', :dependent => :destroy
  has_many :comments, :as => :commentable, :order => 'created_at ASC', :dependent => :destroy
  has_many :reviews, :as => :reviewable, :order => 'created_at ASC', :dependent => :destroy
  
  validates_presence_of :groupable, :title, :body
  
  searches_on :title, :body
  
  def group
    self.groupable.group
  end
  
  def name
    self.title
  end
  
  def locale_name
    self.locale.name if self.locale
  end
  
  def self.find_by_groupable(groupable)
    self.first(:conditions => { :groupable_type => groupable.class.to_s, :groupable_id => groupable.id })
  end
  
  def self.find_all_by_groupable(groupable)
    self.all(:conditions => { :groupable_type => groupable.class.to_s, :groupable_id => groupable.id })
  end
  
  def self.summaries
    all(:conditions => [ 'article_type_id = ?', ArticleType[:summary].id ])
  end
  
  def self.site_contents
    all(:conditions => [ 'article_type_id = ?', ArticleType[:site].id ])
  end
end
