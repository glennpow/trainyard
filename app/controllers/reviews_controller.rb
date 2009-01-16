class ReviewsController < ApplicationController
  make_resourceful do
    belongs_to :reviewable
      
    before :new do
      @review.reviewable = @reviewable
      @review.user = current_user
    end

    response_for :create do |format|
      format.html { redirect_to polymorphic_path([ @review.reviewable, Review.new ]) }
    end

    response_for :update do |format|
      format.html { redirect_to polymorphic_path([ @review.reviewable, Review.new ]) }
    end
  end
 
  def resourceful_name
    t(:review, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_reviewable, :only => [ :index ]
  before_filter :check_may_review, :only => [ :new, :create ]
  before_filter :check_editor_of, :only => [ :edit, :update, :destroy ]
    
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :created_at
      options[:headers] = [
        { :name => t(:from), :sort => :created_at },
        { :name => t(:review, :scope => [ :content ]), :sort => :rating },
      ]

      if @reviewable
        options[:conditions] = [ "reviewable_type = ? AND reviewable_id = ?", @reviewable.class.to_s, @reviewable.id ]
      end
    end
  end

  def list
    respond_with_indexer do |options|
      options[:order] = 'created_at ASC'
      options[:no_table] = true
      options[:per_page] = 5

      if @reviewable
        options[:conditions] = [ "reviewable_type = ? AND reviewable_id = ?", @reviewable.class.to_s, @reviewable.id ]
      end
    end
  end
  
  
  private
  
  def check_reviewable
    check_condition(@reviewable)
  end
 
  def check_may_review
    check_condition(Review.may_review?(@reviewable, current_user))
  end
 
  def check_editor_of
    check_editor(@review)
  end
end
