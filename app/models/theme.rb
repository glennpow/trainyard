class Theme < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def body_background
    "#{self.body_color}#{self.body_url.blank? ? '' : ' url(\'' + self.body_url + '\') repeat'}"
  end
  
  def base_background
    "#{self.base_color}#{self.base_url.blank? ? '' : ' url(' + self.base_url + ') repeat'}"
  end
  
  def primary_background
    "#{self.primary_color}#{self.primary_url.blank? ? '' : ' url(' + self.primary_url + ') repeat'}"
  end
  
  def secondary_background
    "#{self.secondary_color}#{self.secondary_url.blank? ? '' : ' url(' + self.secondary_url + ') repeat'}"
  end
end