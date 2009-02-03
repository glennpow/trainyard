class Organization < ActiveRecord::Base
  acts_as_resource :group => { :dependent => :destroy }
  acts_as_contactable
  acts_as_commentable
  acts_as_reviewable

  has_attached_file :image, Configuration.default_image_options
  has_many_articles
  
  validates_presence_of :name, :description, :group
  validates_uniqueness_of :name, :case_sensitive => false
  validates_attachment_size :image, Configuration.default_image_size_options
  
  searches_on :name, :description
end
