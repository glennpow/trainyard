class Theme < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  has_many :theme_elements, :dependent => :destroy, :order => 'name ASC'
  accepts_nested_attributes_for :theme_elements, :allow_destroy => true
  has_many :root_theme_elements, :class_name => 'ThemeElement', :conditions => { :parent_theme_element_id => nil }, :order => 'position ASC'
  has_many :themeable_themes, :dependent => :destroy
  
  validates_presence_of :name
  
  validates_uniqueness_of :name, :scope => [ :group_id ]
  
  searches_on :name
  
  def find_theme_element_by_name(name)
    self.theme_elements.detect { |theme_element| theme_element.name == name.to_s } || ThemeElement.new
  end
  memoize :find_theme_element_by_name

  def [](name)
    find_theme_element_by_name(name)
  end
end