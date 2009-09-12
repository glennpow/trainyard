class Tagging < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :tag
  
  validates_presence_of :resource, :tag
end