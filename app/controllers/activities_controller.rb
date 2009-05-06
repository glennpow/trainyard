class ActivitiesController < ApplicationController
  make_resource_controller(:actions => [ :destroy ]) do
    belongs_to :user, :resource
  end
  
  def resourceful_name
    t(:activity, :scope => [ :content ])
  end

  before_filter :login_required
  before_filter :check_viewer_of_index, :only => [ :index ]
  before_filter :check_editor_of_activity, :only => [ :destroy ]

  def index
    respond_with_indexer do |options|
      options[:default_sort] = :date
      options[:headers] = []
      options[:headers] << { :name => t(:user, :scope => [ :authentication ]), :sort => :user, :include => :user, :order => "#{User.table_name}.name" } unless @user
      options[:headers] << { :name => t(:date, :scope => [ :datetimes ]), :sort => :created_at }
      options[:headers] << t(:resource)
      options[:headers] << t(:message, :scope => [ :content ])

      options[:conditions] = {}
      options[:conditions][:user_id] = @user.id if @user
    end
  end


  private
  
  def check_viewer_of_index
    @user = if params[:user_id]
      User.find(params[:user_id])
    elsif !has_administrator_role?
      current_user
    else
      nil
    end
    check_condition(has_administrator_role? || current_user == @user)
  end

  def check_editor_of_activity
    check_editor_of(@activity)
  end
end
