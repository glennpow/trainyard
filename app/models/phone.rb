class Phone < ActiveRecord::Base
  belongs_to :phoneable, :polymorphic => true
  has_enumeration :phone_type
  
  validates_presence_of :number
  validates_format_of :number, :with => /^(\(?\d{3}\)?[ .-]?\d{3}[ .-]?\d{4})|(\+\d{2}[ -]?\d{2,4}[ -]?\d{3,4}[ -]?\d{3,4})$/
end
