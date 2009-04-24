class ReviewsController < ApplicationController
  make_resource_controller do
    belongs_to :resource
    
    before :show do
      add_breadcrumb h(@review.resource.name), @review.resource
    end
      
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

  before_filter :check_resource_is_reviewable, :only => [ :index, :new, :create ]
  before_filter :check_may_review, :only => [ :new, :create ]
  before_filter :check_editor_of_review, :only => [ :edit, :update, :destroy ]
    
  def index
    respond_with_indexer do |options|
      options[:order] = 'created_at ASC'
      options[:no_table] = true

      if @resource
        add_breadcrumb h(@resource.name), @resource

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
        add_breadcrumb h(@resource.name), @resource

        options[:conditions] = [ "resource_type = ? AND resource_id = ?", @resource.class.to_s, @resource.id ]
      end
    end
  end
  
  
  private
  
  def check_resource_is_reviewable
    check_condition(is_reviewable?(@resource))
  end
 
  def check_may_review
    check_condition(Review.may_review?(@resource, current_user))
  end
 
  def check_editor_of_review
    check_editor_of(@review)
  end
end
