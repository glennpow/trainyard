class Page < ActiveRecord::Base
  has_many :articles, :as => :resource, :order => 'created_at DESC', :dependent => :destroy
  
  validates_presence_of :permalink
end