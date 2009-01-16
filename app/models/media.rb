class Media < ActiveRecord::Base
  belongs_to :groupable, :polymorphic => true
  has_attached_file :media, :url => "/system/media/:id/:basename.:extension",
    :path => ":rails_root/public/system/media/:id/:basename.:extension"
  has_attached_file :thumbnail, :url => "/system/media/:id/:style_:basename.:extension",
    :path => ":rails_root/public/system/media/:id/:style_:basename.:extension",
    :styles => { :thumb => "100x100#" },
    :default_style => :thumb,
    :default_url => "/images/default/media/missing_thumb.png"
  has_enumeration :content_type

  validates_presence_of :groupable, :name
  
  def source
    self.media.file? ? self.media.url : self.url;
  end
  
  def group
    self.groupable.group
  end
end
