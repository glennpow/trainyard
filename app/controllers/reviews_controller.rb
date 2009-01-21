class ReviewsController < ApplicationController
  make_resourceful do
    belongs_to :resource
      
    before :new do
      @review.user = current_user
    end

    response_for :create do |format|
      format.html { redirect_to polymorphic_path([ @review.resource, Review.new ]) }
    end

    response_for :update do |format|
      format.html { redirect_to polymorphic_path([ @review.resource, Review.new ]) }
    end
  end
 
  def resourceful_name
    t(:review, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_resource, :only => [ :index, :new, :create ]
  before_filter :check_may_review, :only => [ :new, :create ]
  before_filter :check_editor_of, :only => [ :edit, :update, :destroy ]
    
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :created_at
      options[:headers] = [
        { :name => t(:from), :sort => :created_at },
        { :name => t(:review, :scope => [ :content ]), :sort => :rating },
      ]

      if @resource
        options[:conditions] = [ "resource_type = ? AND resource_id = ?", @resource.class.to_s, @resource.id ]
      end
    end
  end

  def list
    respond_with_indexer do |options|
      options[:order] = 'created_at ASC'
      options[:no_table] = true
      options[:per_page] = 5

      if @resource
        options[:conditions] = [ "resource_type = ? AND resource_id = ?", @resource.class.to_s, @resource.id ]
      end
    end
  end
  
  
  private
  
  def check_resource
    logger.info("*** #{@resource} && #{is_reviewable?(@resource)}")
    check_condition(@resource && is_reviewable?(@resource))
  end
 
  def check_may_review
    check_condition(Review.may_review?(@resource, current_user))
  end
 
  def check_editor_of
    check_editor(@review)
  end
end
