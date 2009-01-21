class Comment < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :body
  
  before_save { |comment| comment.body.strip! }
  
  searches_on :body
end
