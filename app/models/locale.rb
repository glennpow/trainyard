class Locale < ActiveRecord::Base
  belongs_to :language
  belongs_to :country
  
  validates_presence_of :language, :country
  
  def code
    "#{self.language.code}-#{self.country.alpha_2_code}"
  end
  
  def name
    "#{self.language.name} (#{self.country.name})"
  end
  
  def localized_name
    "#{self.language.name(self.language.code)} (#{self.country.name})"
  end
  
  def self.parse_language_code(code)
    code[/^[^-]+/]
  end
  
  def self.parse_region_code(code)
    code[/([^-]+)$/]
  end
  
  def self.find_by_code(code)
    language = Language.find_by_code(parse_language_code(code))
    country = Country.find_by_alpha_2_code(parse_region_code(code))
    Locale.find(:first, :conditions => { :language_id => language.id, :country_id => country.id }) if language and country
  end
  
  def self.find_by_name
    all.sort { |x, y| x.name <=> y.name }
  end
   
  def self.find_by_localized_name
    all.sort { |x, y| x.localized_name <=> y.localized_name }
  end

  def self.available_codes
    all.collect { |x| x.code }
  end

  def self.available_language_codes
    all.collect { |x| x.language.code }.uniq
  end
end