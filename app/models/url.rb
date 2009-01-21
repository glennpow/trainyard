class Url < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  has_enumeration :url_type
  
  validates_presence_of :url_address
  # TODO - New regex is needed if Url format is to be validated
  #validates_format_of :url_address, :with => /^(ftp|https?):\/\/((?:[-a-z0-9]+.)+[a-z]{2,})/
end
