class PostsController < ApplicationController
  make_resource_controller do
    belongs_to :forum, :topic, :user
    
    member_actions :edit_guru_points, :update_guru_points
    
    before :show do
      add_breadcrumb h(@post.topic.forum.name), @post.topic.forum
      add_breadcrumb h(@post.topic.name), @post.topic
    end

    before :new do
      add_breadcrumb h(@topic.forum.name), @topic.forum
      add_breadcrumb h(@topic.name), @topic

      if params[:reply_to_post_id]
        @reply_to_post = Post.find(params[:reply_to_post_id])
        @post.quote_from(@reply_to_post)
      end
    end
    
    before :create do
      @post.user = current_user
    end
       
    response_for :create do |format|
      format.html { redirect_to topic_path(@post.topic) }
    end
    
    before :edit do
      add_breadcrumb h(@post.topic.forum.name), @post.topic.forum
      add_breadcrumb h(@post.topic.name), @post.topic
    end

    response_for :update do |format|
      format.html { redirect_to topic_path(@post.topic) }
    end
  end
  
  def resourceful_name
    t(:post, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :new, :create ]
  before_filter :check_administrator_role, :only => [ :destroy ]
  before_filter :check_topic, :only => [ :new, :create ]
  before_filter :check_editor_of_post, :only => [ :edit, :update ]
  before_filter :check_editor_of_guru_points, :only => [ :edit_guru_points, :update_guru_points ]
    
  add_breadcrumb I18n.t(:forum, :scope => [ :content ]).pluralize, :forums_path

  def index
    respond_with_indexer do |options|
      options[:order] = "#{Post.table_name}.created_at ASC"
      options[:search_include] = [ :user ]
      options[:search] = { :context => @topic ? t(:in_object, :object => @topic.name) : t(:in_all_object, :object => tp(:topic, :scope => [ :content ])) }
    
      if @topic
        add_breadcrumb h(@topic.forum.name), @topic.forum
        add_breadcrumb h(@topic.name), @topic

        options[:conditions] = [ "#{Post.table_name}.topic_id = ?", @topic ]
      elsif @forum
        add_breadcrumb h(@forum.name), @forum

        options[:include] = :topic
        options[:conditions] = [ "#{Topic.table_name}.forum_id = ?", @forum ]
      elsif @user
        add_breadcrumb h(@user.name), @user

        options[:conditions] = [ "#{Post.table_name}.user_id = ?", @user ]
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
  
  def check_editor_of_post
    check_editor_of(@post)
  end
  
  def check_editor_of_guru_points
    check_condition(@post.may_edit_guru_points?(current_user))
  end
end
