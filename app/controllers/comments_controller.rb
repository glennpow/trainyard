class CommentsController < ApplicationController
  make_resourceful do
    belongs_to :commentable
      
    before :new do
      @comment.commentable = @commentable
      @comment.user = current_user if logged_in?
    end

    response_for :create do |format|
      format.html { redirect_to polymorphic_path([ @comment.commentable, Comment.new ]) }
    end

    response_for :update do |format|
      format.html { redirect_to polymorphic_path([ @comment.commentable, Comment.new ]) }
    end
  end
 
  def resourceful_name
    t(:comment, :scope => [ :content ])
  end

  before_filter :check_commentable, :only => [ :index ]
  before_filter :check_editor_of, :only => [ :edit, :update, :destroy ]
    
  def index
    respond_with_indexer do |options|
      options[:order] = 'created_at ASC'
      options[:no_table] = true

      if @commentable
        options[:conditions] = [ "commentable_type = ? AND commentable_id = ?", @commentable.class.to_s, @commentable.id ]
      end
    end
  end
    
  def list
    respond_with_indexer do |options|
      options[:order] = 'created_at ASC'
      options[:no_table] = true
      options[:per_page] = 10

      if @commentable
        options[:conditions] = [ "commentable_type = ? AND commentable_id = ?", @commentable.class.to_s, @commentable.id ]
      end
    end
  end
  
  
  private
  
  def check_commentable
    check_condition(@commentable)
  end
 
  def check_editor_of
    check_editor(@comment)
  end
end
