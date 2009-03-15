class ForumsController < ApplicationController
  make_resource_controller do
    member_actions :move_down, :move_up
    
    before :show do
      @topics_indexer = create_indexer(Topic) do |options|
        options[:conditions] = { :forum_id => @forum.id }
        options[:order] = 'topics.sticky DESC, topics.replied_at DESC'
        options[:include] = :user
        options[:headers] = [
          t(:topic, :scope => [ :content ]),
          { :name => tp(:reply), :sort => :posts_count },
          { :name => tp(:view), :sort => :hits },
          t(:last_post, :scope => [ :content ])
        ]
        options[:search_include] = [ :posts, :user ]
        options[:search] = { :url => { :controller => 'topics', :forum_id => @forum.id } }
      end
    end
  end
  
  def resourceful_name
    t(:forum, :scope => [ :content ])
  end

  before_filter :check_administrator_role, :only => [ :new, :create ]
  before_filter :check_moderator_of_forum, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:order] = 'position ASC'
      options[:no_table] = true
      options[:search] = { :url => { :controller => 'topics' } }
    end
  end
  
  def sort
    params[:indexer_forum_form].each_with_index do |id, index|
      Forum.update_all([ 'position = ?', index + 1 ], [ 'id = ?', id ])
    end
    render :nothing => true
  end
  
  def search
    respond_to do |format|
      format.html # search.html.erb
      format.xml  { head :ok }
    end
  end
 
  
  private
  
  def check_moderator_of_forum
    check_moderator_of(@forum)
  end
end
