class Address < ActiveRecord::Base
  if defined?(Geokit)
    #acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude

    before_update do |record|
      record.locate
      true
    end
  end
  
  belongs_to :resource, :polymorphic => true
  belongs_to :region
  belongs_to :country
  
  # FIXME - This doesn't work currently for nested model saving
  #validates_presence_of :resource
  validates_presence_of :street_1, :city, :postal_code, :region, :country
  
  attr_accessor :distance
  
  def streets
    [ self.street_1 ] + (self.street_2.blank? ? [] : [ self.street_2 ])
  end
  
  def full_address
    return @full_address if defined?(@full_address)
    address = []
    address << self.street_1
    address << self.street_2 unless self.street_2.blank?
    address << self.city
    address << self.region.name
    address << self.postal_code
    address << self.country.name
    @full_address = address.join(", ")
  end
  
  def locate
    if defined?(Geokit)
      geo = Geokit::Geocoders::MultiGeocoder.geocode(self.full_address)
      if geo.success
        self.latitude = geo.lat
        self.longitude = geo.lng
        return true
      end
    end
    return false
  end

  def blank?
    self.street_1.blank? && self.street_2.blank? && self.city.blank? && self.region.nil? && self.postal_code.blank? && self.country.nil?
  end
end
