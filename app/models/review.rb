class Review < ActiveRecord::Base
  belongs_to :reviewable, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :user
  
  before_save { |review| review.body.strip! }
  
  searches_on :body

  def self.may_review?(reviewable, user)
    (reviewable.nil? || user.nil?) ? false : reviewable.reviews.detect { |review| review.user_id == user.id }.nil?
  end
  
  def self.rating_for(reviewable)
    reviewable.reviews.any? ? reviewable.reviews.inject(0) { |rating, review| rating += review.rating } / reviewable.reviews.count : 0
  end
end
