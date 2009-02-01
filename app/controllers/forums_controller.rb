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

  before_filter :login_required, :only => [ :edit, :update, :destroy ]
  before_filter :check_administrator_role, :only => [ :new, :create ]
  before_filter :check_moderator_of, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:order] = 'position ASC'
      options[:headers] = [
        t(:forum, :scope => [ :content ]),
        tp(:topic, :scope => [ :content ]),
        tp(:post, :scope => [ :content ]),
      ]
      options[:search] = { :url => { :controller => 'topics' } }
    end
  end
  
  def move_down
    @forum.move_lower
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
  
  def move_up
    @forum.move_higher
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
  
  def search
    respond_to do |format|
      format.html # search.html.erb
      format.xml  { head :ok }
    end
  end
 
  
  private
  
  def check_moderator_of
    check_moderator(@forum)
  end
end
