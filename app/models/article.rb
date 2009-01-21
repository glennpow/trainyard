class Article < ActiveRecord::Base
  acts_as_commentable
  acts_as_reviewable
  
  belongs_to :resource, :polymorphic => true
  belongs_to :locale
  has_many :medias, :as => :resource, :order => 'created_at ASC', :dependent => :destroy
  
  validates_presence_of :resource, :name, :body
  
  searches_on :name, :body
  
  def locale_name
    self.locale.name if self.locale
  end
  
  def self.first_by_resource(resource)
    self.first(:conditions => { :resource_type => resource.class.to_s, :resource_id => resource.id })
  end
  
  def self.all_by_resource(resource)
    self.all(:conditions => { :resource_type => resource.class.to_s, :resource_id => resource.id })
  end
end
