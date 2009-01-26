class PostsController < ApplicationController
  make_resourceful do
    belongs_to :topic
    
    member_actions :edit_guru_points, :update_guru_points
    
    before :new do
      if params[:reply_to_post_id]
        @reply_to_post = Post.find(params[:reply_to_post_id])
        @post.quote_from(@reply_to_post)
      end
    end
    
    before :create do
      @post.user = current_user
    end

    response_for :update do |format|
      format.html { redirect_to topic_path(@post.topic) }
    end
  end
  
  def resourceful_name
    t(:post, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :new, :create, :edit, :update ]
  before_filter :check_administrator_role, :only => [ :destroy ]
  before_filter :check_topic, :only => [ :new, :create ]
  before_filter :check_editor_of, :only => [ :edit, :update ]
  before_filter :check_editor_of_guru_points, :only => [ :edit_guru_points, :update_guru_points ]
  
  def index
    respond_with_indexer do |options|
      options[:order] = 'posts.created_at ASC'
      options[:search_include] = [ :user ]
      options[:search] = { :context => @topic ? t(:in_object, :object => @topic.name) : t(:in_all_object, :object => tp(:topic, :scope => [ :content ])) }
    
      if params[:topic_id]
        options[:conditions] = [ 'posts.topic_id = ?', params[:topic_id] ]
      elsif params[:forum_id]
        options[:include] = :topic
        options[:conditions] = [ 'topics.forum_id = ?', params[:forum_id] ]
      end
    end
  end
  
  def edit_guru_points
  end
  
  def update_guru_points
    if @post.update_attribute(:guru_points, params[:post][:guru_points])
      flash[:notice] = t(:object_updated, :object => t(:post, :scope => [ :content ]))
      redirect_to :action => 'index', :topic_id => @post.topic_id
    else
      flash[:error] = t(:object_not_updated, :object => t(:post, :scope => [ :content ]))
      render :action => 'edit_guru_points'
    end
  end
  
  
  private
  
  def check_topic
    check_condition(@topic)
  end
  
  def check_editor_of
    check_editor(@post)
  end
  
  def check_editor_of_guru_points
    check_condition(@post.may_edit_guru_points?(current_user))
  end
end
