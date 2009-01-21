class ArticlesController < ApplicationController
  make_resourceful do
    belongs_to :resource
    
    before :show do
      load_comments(@article)
      load_reviews(@article)
    end
  end
  
  def resourceful_name
    t(:article, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :index, :new, :create, :edit, :update, :destroy ]
  before_filter :check_editor_or_administrator, :only => [ :index ]
  before_filter :check_resource, :only => [ :new, :create ]
  before_filter :check_editor_of, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_viewer_of, :only => [ :show ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:title, :scope => [ :content ]), :sort => :name },
        t(:topic, :scope => [ :content ]),
        t(:locale, :scope => [ :content ])
      ]
      options[:search] = true
    
      options[:conditions] = {}
      if @resource
        options[:conditions][:resource_type] = @resource.class.to_s
        options[:conditions][:resource_id] = @resource.id
      elsif params[:resource_type]
        options[:conditions][:resource_type] = params[:resource_type]
      end
    end
  end
  
  
  private
  
  def check_editor_or_administrator
    @resource ? check_editor_of : check_administrator_role
  end
  
  def check_resource
    check_condition(@resource)
  end
  
  def check_viewer_of
    check_viewer(@article)
  end
  
  def check_editor_of
    check_editor(@resource || @article)
  end
end
