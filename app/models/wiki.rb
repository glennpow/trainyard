class Wiki < ActiveRecord::Base
  acts_as_resource

  has_many_articles :revisionable => true
    
  validates_presence_of :group, :name
  
  searches_on :name
end
