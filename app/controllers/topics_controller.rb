class TopicsController < ApplicationController
  make_resourceful do
    belongs_to :forum
    
    before :show do
      @posts_indexer = create_indexer(Post) do |options|
        options[:conditions] = { :topic_id => @topic.id }
        options[:order] = 'posts.created_at ASC'
        options[:include] = :topic
        options[:search] = { :url => { :controller => 'posts', :topic_id => @topic.id } }
      end

      @topic.hit! unless logged_in? && @topic.user_id == current_user.id
    end
    
    before :new do
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
  end
  
  def resourceful_name
    t(:topic, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :new, :create ]
  before_filter :check_forum, :only => [ :new, :create ]
  before_filter :check_administrator_role, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:order] = 'topics.sticky DESC, topics.replied_at DESC'
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
        options[:conditions] = [ 'topics.forum_id = ?', params[:forum_id] ]
      end
    end
  end
  
  
  private
  
  def check_forum
    check_condition(@forum)
  end
end
