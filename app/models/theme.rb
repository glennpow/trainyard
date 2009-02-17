class Theme < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def body_color_background
    @body_color_background ||= "#{self.body_color} #{self.body_background}"
  end
  
  def base_color_background
    @base_color_background ||= "#{self.base_color} #{self.base_background}"
  end
  
  def primary_color_background
    @primary_color_background ||= "#{self.primary_color} #{self.primary_background}"
  end
  
  def secondary_color_background
    @secondary_color_background ||= "#{self.secondary_color} #{self.secondary_background}"
  end
  
  def highlight_color_background
    @highlight_color_background ||= "#{self.highlight_color} #{self.highlight_background}"
  end
end