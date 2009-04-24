class BlogsController < ApplicationController
  make_resource_controller do
    belongs_to :group
    
    member_actions :article, :contents
    
    before :show do
      @articles_indexer = create_indexer(Article) do |options|
        options[:order] = 'created_at DESC'
        options[:search] = { :url => { :action => 'contents' } }
        options[:row] = 'blogs/article_indexed'
        options[:no_table] = true
        options[:locals] = { :blog => @blog }

        options[:conditions] = { :resource_type => 'Blog', :resource_id => @blog.id }
      end
    end
  end
  
  def resourceful_name
    t(:blog, :scope => [ :content ])
  end

  before_filter :check_editor_of_group, :only => [ :new, :create ]
  before_filter :check_editor_of_blog, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:title, :scope => [ :content ]), :sort => :name },
        t(:group, :scope => [ :authentication ]),
      ]
      options[:search] = true

      options[:conditions] = { :group_id => @group.id } if @group
    end
  end
  
  def article
    add_breadcrumb h(@blog.name), @blog
    add_breadcrumb h(@article.name)

    @article = params[:article_id] ? Article.find(params[:article_id]) : @blog.articles.first
    
    if @article
      load_comments(@article)
      load_reviews(@article)
    end
  end
  
  def contents
    @articles_indexer = create_indexer(Article) do |options|
      options[:order] = 'created_at DESC'
      options[:search] = { :url => { :action => 'contents' } }
      options[:row] = 'blogs/article_indexed'
      options[:no_table] = true
      options[:locals] = { :blog => @blog }

      options[:conditions] = { :resource_type => 'Blog', :resource_id => @blog.id }
    end
  end
  
  
  private
  
  def check_editor_of_group
    check_editor_of(@group)
  end
  
  def check_editor_of_blog
    check_editor_of(@blog)
  end
end
