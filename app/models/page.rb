class Page < ActiveRecord::Base
  acts_as_resource :group => false
  
  has_many_articles
  
  validates_presence_of :name, :permalink
end