class Wiki < ActiveRecord::Base
  acts_as_resource

  has_many_articles :order => 'name ASC', :revisionable => true
    
  validates_presence_of :name
  
  searches_on :name
  
  def heirarchical_articles?
    true
  end
end
