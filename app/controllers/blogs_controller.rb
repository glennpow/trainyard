class BlogsController < ApplicationController
  make_resourceful do
    belongs_to :group
    
    member_actions :article, :contents
    
    before :show do
      @articles_indexer = create_indexer(Article) do |options|
        options[:order] = 'created_at DESC'
        options[:search] = { :url => { :action => 'contents' } }
        options[:row] = 'blogs/article_indexed'
        options[:no_table] = true
        options[:locals] = { :blog => @blog }

        options[:conditions] = { :groupable_type => 'Blog', :groupable_id => @blog.id }
      end
    end
  end
  
  def resourceful_name
    t(:blog, :scope => [ :blogs ])
  end

  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_editor_of, :only => [ :new, :create, :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :title
      options[:headers] = [
        { :name => t(:title, :scope => [ :content ]), :sort => :title },
        t(:group, :scope => [ :authenticate ]),
        { :name => t(:date, :scope => [ :datetimes ]), :sort => :article_type, :include => :created_at }
      ]
      options[:search] = true

      options[:conditions] = { :group_id => @group.id } if @group
    end
  end
  
  def article
    @article = params[:article_id] ? Article.find(params[:article_id]) : @blog.articles.first
    
    if @article
      @comments_indexer = create_indexer(Comment) do |options|
        options[:order] = 'created_at ASC'
        options[:no_table] = true
        options[:per_page] = 10

        options[:conditions] = [ "commentable_type = ? AND commentable_id = ?", 'Article', @article.id ]
        options[:paginate] = { :params => { :controller => 'comments', :action => 'list', :article_id => @article.id } }
      end

      @reviews_indexer = create_indexer(Review) do |options|
        options[:order] = 'created_at ASC'
        options[:no_table] = true
        options[:per_page] = 5

        options[:conditions] = [ "reviewable_type = ? AND reviewable_id = ?", 'Article', @article.id ]
        options[:paginate] = { :params => { :controller => 'reviews', :action => 'list', :article_id => @article.id } }
      end
    end
  end
  
  def contents
    @articles_indexer = create_indexer(Article) do |options|
      options[:order] = 'created_at DESC'
      options[:search] = { :url => { :action => 'contents' } }
      options[:row] = 'blogs/article_indexed'
      options[:no_table] = true
      options[:locals] = { :blog => @blog }

      options[:conditions] = { :groupable_type => 'Blog', :groupable_id => @blog.id }
    end
  end
  
  
  private
  
  def check_editor_of
    check_editor(@group || @blog)
  end
end
