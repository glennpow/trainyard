class ArticleRevisionsController < ApplicationController
  make_resource_controller(:actions => [ :show ]) do
    belongs_to :article
  end
  
  def resourceful_name
    t(:revision, :scope => [ :content ])
  end

  before_filter :check_article, :only => [ :index ]
  before_filter :check_editor_of_article, :only => [ :index ]
  before_filter :check_editor_of_article_revision, :only => [ :show ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:title, :scope => [ :content ]), :sort => :name },
        { :name => t(:author, :scope => [ :content ]), :include => :user, :sort => :user, :order => "#{User.table_name}.name" },
        { :name => t(:revision, :scope => [ :content ]), :sort => :revision },
        { :name => t(:date, :scope => [ :datetimes ]), :sort => :updated_at },
      ]
      options[:search] = true
    
      options[:conditions] = { :article_id => @article.id }
    end
  end
  
  
  private
  
  def check_article
    check_condition(@article)
  end
  
  def check_editor_of_article
    check_editor_of(@article)
  end
  
  def check_editor_of_article_revision
    check_editor_of(@article_revision)
  end
end
