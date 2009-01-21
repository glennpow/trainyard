class Review < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :user
  
  before_save { |review| review.body.strip! }
  
  searches_on :body

  def self.may_review?(resource, user)
    (resource.nil? || user.nil?) ? false : resource.reviews.detect { |review| review.user_id == user.id }.nil?
  end
  
  def self.rating_for(resource)
    resource.reviews.any? ? resource.reviews.inject(0) { |rating, review| rating += review.rating } / resource.reviews.count : 0
  end
end
