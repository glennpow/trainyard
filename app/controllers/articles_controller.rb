class ArticlesController < ApplicationController
  make_resourceful do
    belongs_to :groupable
  end
  
  def resourceful_name
    t(:article, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :index, :new, :create, :edit, :update, :destroy ]
  before_filter :check_editor_or_administrator, :only => [ :index ]
  before_filter :check_editor_of, :only => [ :new, :create, :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :title
      options[:headers] = [
        { :name => t(:title, :scope => [ :content ]), :sort => :title },
        t(:topic, :scope => [ :content ]),
        { :name => t(:type), :sort => :article_type, :include => :article_type, :order => 'article_types.name' },
        t(:locale, :scope => [ :content ])
      ]
      options[:search] = true
    
      options[:conditions] = {}
      if @groupable
        options[:conditions][:groupable_type] = @groupable.class.to_s
        options[:conditions][:groupable_id] = @groupable.id
      end
      options[:conditions][:article_type_id] = ArticleType[params[:article_type].to_sym].id if params[:article_type]
    end
  end
  
  
  private
  
  def check_editor_or_administrator
    if @groupable
      check_editor_of
    else
      check_administrator_role
    end
  end
  
  def check_editor_of
    check_editor(@groupable || @article)
  end
end
