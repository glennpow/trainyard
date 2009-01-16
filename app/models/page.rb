class Page < ActiveRecord::Base
  belongs_to :group
  has_many :articles, :as => :groupable, :order => 'created_at DESC', :dependent => :destroy
  
  validates_presence_of :group
end