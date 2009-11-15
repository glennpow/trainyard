class Membership < ActiveRecord::Base
  belongs_to :group, :counter_cache => true
  has_enumeration :role
  belongs_to :user
  has_many :permissions, :through => :group
  
  validates_presence_of :role, :user
end