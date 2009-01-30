class ArticlesController < ApplicationController
  make_resourceful do
    belongs_to :resource
    
    member_actions :erase
    
    before :show do
      load_comments(@article)
      load_reviews(@article)
    end
    
    before :new do
      @article.group = @resource.group
      @article.user = current_user
      @article.heirarchical = @resource.heirarchical_articles? if @resource.respond_to?(:heirarchical_articles?)
      @article.commentable = @resource.commentable_articles? if @resource.respond_to?(:commentable_articles?)
      @article.reviewable = @resource.reviewable_articles? if @resource.respond_to?(:reviewable_articles?)
      @article.revisionable = @resource.revisionable_articles? if @resource.respond_to?(:revisionable_articles?)
    end
    
    before :edit do
      @article.user = current_user
    end
  end
  
  def resourceful_name
    t(:article, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :index, :new, :create, :edit, :update, :destroy, :erase ]
  before_filter :check_administrator_role, :only => [ :destroy ]
  before_filter :check_viewer_or_administrator, :only => [ :index ]
  before_filter :check_add_article_for, :only => [ :new, :create ]
  before_filter :check_editor_of, :only => [ :edit, :update, :erase ]
  before_filter :check_viewer_of, :only => [ :show ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:title, :scope => [ :content ]), :sort => :name },
        { :name => t(:author, :scope => [ :content ]), :sort => :author, :include => :user, :order => "#{User.table_name}.name" },
        t(:resource),
        { :name => t(:date, :scope => [ :datetimes ]), :sort => :updated_at },
        t(:locale, :scope => [ :content ])
      ]
      options[:search] = true
    
      if @resource
        options[:conditions] = { :resource_type => @resource.class.to_s, :resource_id => @resource.id }
      elsif params[:resource_type]
        options[:conditions] = { :resource_type => params[:resource_type] }
      end
    end
  end

  def erase
    @article.update_attributes(:user_id => current_user, :erased => true)

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
  
  
  private
  
  def check_viewer_or_administrator
    @resource ? check_viewer(@resource) : check_administrator_role
  end
  
  def check_add_article_for
    check_permission(Action.add_article, @resource)
  end
  
  def check_editor_of
    check_editor(@article)
  end
  
  def check_viewer_of
    check_viewer(@article)
  end
end
