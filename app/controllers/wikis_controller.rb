class WikisController < ApplicationController
  make_resourceful do
    belongs_to :group
    
    before :show do
      @articles_indexer = create_indexer(Article) do |options|
        options[:default_sort] = :name
        options[:headers] = [
          { :name => t(:title, :scope => [ :content ]), :sort => :name },
          { :name => t(:author, :scope => [ :content ]), :sort => :author, :include => :user, :order => "#{User.table_name}.name" },
          t(:topic, :scope => [ :content ]),
          { :name => t(:date, :scope => [ :datetimes ]), :sort => :updated_at },
          t(:locale, :scope => [ :content ])
        ]
        options[:search] = { :url => wiki_articles_path(@wiki) }

        options[:conditions] = { :resource_id => @wiki.id, :resource_type => 'Wiki' }
      end
    end
  end
  
  def resourceful_name
    t(:wiki, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_group, :only => [ :index, :new, :create ]
  before_filter :check_editor_of, :only => [ :new, :create, :edit, :update, :destroy ]
  
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
  
  
  private
  
  def check_group
    check_condition(has_administrator_role? || @group)
  end
  
  def check_editor_of
    check_editor(@group || @wiki)
  end
end