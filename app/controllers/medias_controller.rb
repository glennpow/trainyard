class MediasController < ApplicationController
  make_resourceful do
    belongs_to :groupable
  end
  
  def resourceful_name
    t(:media, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :index, :new, :create, :edit, :update, :destroy ]
  before_filter :check_editor_of, :only => [ :index, :new, :create, :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:conditions] = { :groupable_id => @groupable, :groupable_type => @groupable.class.to_s }
      options[:default_sort] = :created_at
      options[:headers] = [
        { :name => t(:title, :scope => [ :content ]), :sort => :title },
        t(:group, :scope => [ :authenticate ]),
        { :name => t(:date, :scope => [ :datetimes ]), :sort => :article_type, :include => :created_at }
      ]
    end
  end
  
  
  private
  
  def check_editor_of
    check_editor(@groupable || @media)
  end
end
