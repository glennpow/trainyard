class Address < ActiveRecord::Base
  if defined?(Geographer)
    acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude,
      :auto_geocode => { :field => :full_address, :error_message => I18n.t(:invalid_address, :scope => [ :contacts ]) }
  end
  
  belongs_to :addressable, :polymorphic => true
  belongs_to :region
  belongs_to :country
  
  validates_presence_of :street_1, :city, :postal_code, :region, :country

  before_validation_on_update :auto_geocode_address        
  
  attr_accessible :distance
  
  def streets
    [ self.street_1 ] + (self.street_2.blank? ? [] : [ self.street_2 ])
  end
  
  def full_address(options = {})
    address = []
    address << self.street_1
    address << self.street_2 unless self.street_2.blank?
    address << self.city
    address << self.region.name
    address << self.postal_code
    address << self.country.alpha_3_code
    address.join(", ")
  end

  def blank?
    self.street_1.blank? && self.street_2.blank? && self.city.blank? && self.region.nil? && self.postal_code.blank? && self.country.nil?
  end
end
