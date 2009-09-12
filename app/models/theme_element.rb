class ThemeElement < ActiveRecord::Base
  acts_as_list
  acts_as_tree

  belongs_to :theme
  has_enumeration :background_repeat
  
  validates_presence_of :theme, :name
  validates_uniqueness_of :name, :scope => [ :theme_id ]
  
  cattr_reader :inheritable_theme_attributes
  
  @@inheritable_theme_attributes = [ :background_color, :background_url, :background_x, :background_y, :background_repeat,
    :background_attachment, :font_color, :link_color, :link_hover_color ]
    
  def display_name
    self.name.camelize
  end
  
  def background_url_css
    @background_url_css ||= self.background_url.blank? ? 'none' : "url('#{self.background_url}')"
  end
  
  def background_repeat_css
    @background_repeat_css ||= self.background_repeat.to_s.gsub(/_/, '-')
  end

  def background
    @background ||= [ self.background_color, self.background_url_css, self.background_x, self.background_y, self.background_repeat_css, self.background_attachment ].join(' ')
  end
  
  class_eval do
    self.inheritable_theme_attributes.each do |attribute|
      define_method attribute do
        return super unless self.inherit? && !self.parent.nil?
        self.parent.send(attribute)
      end
    end
  end
end