class Email < ActiveRecord::Base
  belongs_to :emailable, :polymorphic => true
  has_enumeration :email_type
  
  validates_presence_of :email_address
  validates_format_of :email_address, :with => /^[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)$/i
end
