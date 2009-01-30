class Blog < ActiveRecord::Base
  acts_as_resource
  
  has_many_articles :order => 'created_at DESC'
    
  validates_presence_of :name
  
  searches_on :name
end
