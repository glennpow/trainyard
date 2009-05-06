class FriendshipsController < ApplicationController
  before_filter :login_required
  before_filter :check_editor_of_friendship, :only => [ :accept, :destroy ]
  before_filter :check_user, :only => [ :create ]
  before_filter :check_viewer_of_index, :only => [ :index ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :user
      options[:headers] = [
        { :name => t(:user, :scope => [ :authentication ]), :sort => :user, :include => :friend, :order => "#{User.table_name}.name" },
        t(:type),
        t(:date, :scope => [ :datetimes ])
      ]

      options[:conditions] = { :user_id => @user.id }
      if @friendship_type
        options[:conditions][:friendship_type] = @friendship_type
      end
    end
  end
      
  def create
    if Friendship.request(current_user, @user)
      flash[:notice] = t(:success, :scope => [ :social, :friendships, :request ], :user => h(@user.name))
    else
      flash[:error] = t(:failure, :scope => [ :social, :friendships, :request ], :user => h(@user.name))
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
     
  def destroy
    @user = @friendship.friend
    if @friendship.destroy
      flash[:notice] = t(:success, :scope => [ :social, :friendships, :remove ], :user => h(@user.name))
    else
      flash[:error] = t(:failure, :scope => [ :social, :friendships, :remove ], :user => h(@user.name))
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
  
  def accept
    if @friendship.accept
      flash[:notice] = t(:success, :scope => [ :social, :friendships, :accept ], :user => h(@friendship.friend.name))
    else
      flash[:error] = t(:failure, :scope => [ :social, :friendships, :accept ], :user => h(@friendship.friend.name))
    end

    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
  
  
  private
  
  def check_editor_of_friendship
    @friendship = Friendship.find(params[:id]) if params[:id]
    check_editor_of(@friendship)
  end
  
  def check_user
    @user = User.find(params[:user_id]) if params[:user_id]
    check_condition(@user)
  end
  
  def check_viewer_of_index
    @user = if params[:user_id]
      User.find(params[:user_id])
    else
      current_user
    end
    @friendship_type = FriendshipType[params[:friendship_type]] if params[:friendship_type]
    check_condition(has_administrator_role? || current_user == @user)
  end
end
