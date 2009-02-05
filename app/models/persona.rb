class Persona < ActiveRecord::Base
  belongs_to :user
  has_enumeration :prefix
  has_enumeration :suffix
  has_enumeration :gender
  
  # FIXME - This doesn't work currently for nested model saving
  #validates_presence_of :user

  searches_on :first_name, :middle_name, :last_name
  
  def full_name
    return @full_name if defined?(@full_name)
    name = []
    name << self.prefix.name if self.prefix
    name << self.first_name unless self.first_name.blank?
    name << self.middle_name unless self.middle_name.blank?
    name << self.last_name unless self.last_name.blank?
    name << self.suffix.name if self.suffix
    @full_name = name.join(" ")
    @full_name
  end
  
  def blank?
    self.first_name.blank? && self.middle_name.blank? && self.last_name.blank? && self.prefix.nil? && self.suffix.nil? && self.gender.nil?
  end
end
