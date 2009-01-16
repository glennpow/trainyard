class UserConfig < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user
  validates_uniqueness_of :user_id
end