class CommentsController < ApplicationController
  make_resource_controller do
    belongs_to :resource
    
    before :show do
      add_breadcrumb h(@comment.resource.name), @comment.resource
    end
      
    before :new do
      @comment.user = current_user if logged_in?
    end
  
    before :create do
      verify_human(@comment)
    end

    response_for :create do |format|
      format.html { redirect_to polymorphic_path([ @comment.resource, Comment.new ]) }
    end

    response_for :update do |format|
      format.html { redirect_to polymorphic_path([ @comment.resource, Comment.new ]) }
    end
  end
 
  def resourceful_name
    t(:comment, :scope => [ :content ])
  end

  before_filter :check_resource_is_commentable, :only => [ :index, :new, :create ]
  before_filter :check_editor_of_comment, :only => [ :edit, :update, :destroy ]
  
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
      options[:per_page] = 10

      if @resource
        add_breadcrumb h(@resource.name), @resource

        options[:conditions] = [ "resource_type = ? AND resource_id = ?", @resource.class.to_s, @resource.id ]
      end
    end
  end
  
  
  private
  
  def check_resource_is_commentable
    check_condition(is_commentable?(@resource))
  end
 
  def check_editor_of_comment
    check_editor_of(@comment)
  end
end
