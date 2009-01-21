class Country < ActiveRecord::Base
  has_many :regions
  
  validates_presence_of :alpha_3_code
  validates_length_of :alpha_2_code, :is => 2
  validates_length_of :alpha_3_code, :is => 3
  
  def initialize(attributes = nil)
    super
    self.official_name ||= name unless attributes && attributes.include?(:official_name)
  end
  
  def name
    I18n.t(self.alpha_2_code, :scope => [ :countries ])
  end
  
  def self.by_name
    self.all.sort { |a, b| a.name <=> b.name }
  end
end
