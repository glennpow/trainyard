class Blog < ActiveRecord::Base
  belongs_to :group
  has_many :articles, :as => :resource, :order => 'created_at DESC', :dependent => :destroy
  
  validates_presence_of :group, :name
  
  searches_on :name
  
  def posted_at
    (self.articles.first || self).created_at
  end
end
