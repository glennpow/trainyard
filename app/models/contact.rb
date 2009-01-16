class Contact < ActiveRecord::Base
  belongs_to :contactable, :polymorphic => true
  has_enumeration :prefix
  has_enumeration :suffix
  has_enumeration :gender
  has_one :address, :as => :addressable, :dependent => :destroy
  has_many :emails, :as => :emailable, :dependent => :destroy
  has_many :phones, :as => :phoneable, :dependent => :destroy
  has_many :urls, :as => :urlable, :dependent => :destroy
    
  has_accessible :address, :emails, :phones, :urls

  searches_on :first_name, :middle_name, :last_name
  
  def full_name
    name = []
    name << self.prefix.name if self.prefix
    name << self.first_name unless self.first_name.blank?
    name << self.middle_name unless self.middle_name.blank?
    name << self.last_name unless self.last_name.blank?
    name << self.suffix.name if self.suffix
    name.join(" ")
  end
  
  def locale
    Locale.new(self.language, self.country)
  end
  
  def blank?
    self.first_name.blank? && self.middle_name.blank? && self.last_name.blank? && self.prefix.nil? && self.suffix.nil? && self.gender.nil? && self.address.blank? && self.emails.empty? && self.phones.empty? && self.urls.empty?
  end
end
