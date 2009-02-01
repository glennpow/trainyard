class Url < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  has_enumeration :url_type
  
  validates_presence_of :url_address
end
