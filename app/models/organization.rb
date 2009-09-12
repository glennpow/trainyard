class Organization < ActiveRecord::Base
  acts_as_resource :group => { :dependent => :destroy }
  acts_as_contactable
  acts_as_commentable
  acts_as_reviewable
  acts_as_mappable :through => :address

  has_attached_file :image, Configuration.default_image_options
  has_many_articles
  has_one_theme
  
  validates_presence_of :name, :group
  validates_uniqueness_of :name, :case_sensitive => false
  validates_attachment_size :image, Configuration.default_image_size_options
  validates_attachment_content_type :image, :content_type => Configuration.default_image_content_types
  
  searches_on :name, :description
  
  def organizables(*args)
    ([ args ].flatten).map do |klass|
      klass.find_all_by_organization_id(self.id)
    end.flatten
  end
end
