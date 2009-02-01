class WatchingsController < ApplicationController
  make_resource_controller(:actions => [ :create, :destroy ]) do
    belongs_to :user, :resource
    
    before :create do
      @watching.user = current_user
    end
    
    response_for :create do |format|
      format.html { redirect_to :back }
    end
  end
  
  def resourceful_name
    t(:watch, :scope => [ :content ])
  end

  before_filter :login_required, :only => [ :index, :create, :destroy ]
  before_filter :check_index, :only => [ :index ]
  before_filter :check_editor_of, :only => [ :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :user
      options[:headers] = []
      options[:headers] << { :name => t(:user, :scope => [ :authentication ]), :sort => :user } unless @user
      options[:headers] << t(:resource) unless @resource
      options[:headers] << t(:date, :scope => [ :datetimes ])

      options[:conditions] = {}
      if @user
        options[:conditions] = { :user_id => @user.id }
      end
      if @resource
        options[:conditions][:resource_type] = @resource.class.to_s
        options[:conditions][:resource_id] = @resource.id
      elsif params[:resource_type]
        options[:conditions][:resource_type] = params[:resource_type]
      end
    end
  end
  
  
  private
  
  def check_index
    @user ? check_condition(@user.id == current_user.id) : check_viewer_of(@resource)
  end
  
  def check_editor_of
    check_condition(@watching.user_id == current_user.id)
  end
end
