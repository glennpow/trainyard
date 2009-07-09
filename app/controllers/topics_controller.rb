class TopicsController < ApplicationController
  make_resource_controller do
    belongs_to :forum
    
    before :show do
      add_breadcrumb h(@topic.forum.name), @topic.forum
      add_breadcrumb h(@topic.name)

      @posts_indexer = create_indexer(Post) do |options|
        options[:conditions] = { :topic_id => @topic.id }
        options[:order] = 'posts.created_at ASC'
        options[:include] = :topic
        options[:search] = { :url => { :controller => 'posts', :topic_id => @topic.id } }
      end

      @topic.hit! unless is_editor_of?(@topic)
    end
    
    before :new do
      add_breadcrumb h(@forum.name), @forum

      @post = Post.new
    end
    
    before :create do
      @topic.user = current_user
    end
    
    after :create do
      @post = Post.new(params[:post])
      @post.user = current_user
      @topic.posts << @post
    end
    
    before :edit do
      add_breadcrumb h(@topic.forum.name), @topic.forum
    end
  end
  
  def resourceful_name
    t(:topic, :scope => [ :content ])
  end

  before_filter :check_logged_in, :only => [ :new, :create ]
  before_filter :check_forum, :only => [ :new, :create ]
  before_filter :check_administrator_role, :only => [ :edit, :update, :destroy ]
    
  add_breadcrumb I18n.t(:forum, :scope => [ :content ]).pluralize, :forums_path

  def index
    add_breadcrumb h(@forum.name), @forum

    respond_with_indexer do |options|
      options[:order] = "#{Topic.table_name}.sticky DESC, #{Topic.table_name}.replied_at DESC"
      options[:include] = :user
      options[:headers] = [
        t(:topic, :scope => [ :content ]),
        { :name => tp(:reply), :sort => :posts_count },
        { :name => tp(:view), :sort => :hits },
        t(:last_post, :scope => [ :content ])
      ]
      options[:search_include] = [ :posts, :user ]
      options[:search] = { :context => @forum ? t(:in_object, :object => @forum.name) : t(:in_all_object, :object => tp(:forum, :scope => [ :content ])) }
        
      if params[:forum_id]
        options[:conditions] = [ "#{Topic.table_name}.forum_id = ?", params[:forum_id] ]
      end
    end
  end
  
  
  private
  
  def check_forum
    check_condition(@forum)
  end
end
