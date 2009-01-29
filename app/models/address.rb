class Address < ActiveRecord::Base
  if defined?(Geokit)
    acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude

    before_update do |record|
      geo = Geokit::Geocoders::MultiGeocoder.geocode(self.full_address)
      if geo.success
        self.latitude = geo.lat
        self.longitude = geo.lng
      end
      true
    end
  end
  
  belongs_to :contact
  belongs_to :region
  belongs_to :country
  
  validates_presence_of :contact, :street_1, :city, :postal_code, :region, :country
  
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
    @full_address
  end

  def blank?
    self.street_1.blank? && self.street_2.blank? && self.city.blank? && self.region.nil? && self.postal_code.blank? && self.country.nil?
  end
end
