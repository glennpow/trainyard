class MediasController < ApplicationController
  make_resource_controller do
    belongs_to :resource
  end
  
  def resourceful_name
    t(:media, :scope => [ :content ])
  end

  before_filter :check_editor_of_resource, :only => [ :index, :new, :create ]
  before_filter :check_editor_of_media, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:conditions] = { :resource_id => @resource, :resource_type => @resource.class.to_s }
      options[:default_sort] = :created_at
      options[:headers] = [
        { :name => t(:title, :scope => [ :content ]), :sort => :name },
        t(:group),
      ]
    end
  end
  
  
  private
  
  def check_editor_of_resource
    check_editor_of(@resource, true)
  end
  
  def check_editor_of_media
    check_editor_of(@media)
  end
end
