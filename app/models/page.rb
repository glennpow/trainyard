class Page < ActiveRecord::Base
  acts_as_resource
  
  has_many_articles
  
  validates_presence_of :group, :name, :permalink
end