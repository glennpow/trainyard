class Region < ActiveRecord::Base
  belongs_to :country
  
  validates_presence_of :country_id, :alpha_code
  validates_length_of :alpha_code, :within => 1..5
  
  def initialize(attributes = nil)
    super
    self.alpha_code ||= default_alpha_code unless attributes && attributes.include?(:alpha_code)
  end

  def iso_code
    "#{country}-#{alpha_code}"
  end
  
  def name
    I18n.t(self.alpha_code, :scope => [ :regions ])
  end
  
  def self.by_name
    self.all.sort(&:name)
  end


  private

  def default_alpha_code
    "%03d" % (numeric_code % 1000) if numeric_code
  end
end
