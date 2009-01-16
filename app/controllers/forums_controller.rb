class ForumsController < ApplicationController
  make_resourceful do
    member_actions :move_down, :move_up
    
    before :show do
      @topics_indexer = create_indexer(Topic) do |options|
        options[:conditions] = { :forum_id => @forum.id }
        options[:order] = 'topics.sticky DESC, topics.replied_at DESC'
        options[:include] = :user
        options[:headers] = [
          t(:topic, :scope => [ :forums ]),
          { :name => tp(:reply), :sort => :posts_count },
          { :name => tp(:view), :sort => :hits },
          t(:last_post, :scope => [ :forums ])
        ]
        options[:search_include] = [ :posts, :user ]
        options[:search] = { :url => { :controller => 'topics', :forum_id => @forum.id } }
      end
    end
  end
  
  def resourceful_name
    t(:forum, :scope => [ :forums ])
  end

  before_filter :login_required, :only => [ :edit, :update, :destroy ]
  before_filter :check_administrator_role, :only => [ :new, :create ]
  before_filter :check_moderator_of, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:order] = 'position ASC'
      options[:headers] = [
        t(:forum, :scope => [ :forums ]),
        tp(:topic, :scope => [ :forums ]),
        tp(:post, :scope => [ :forums ]),
      ]
      options[:search] = { :url => { :controller => 'topics' } }
    end
  end
  
  def move_down
    @forum.move_lower
    
    redirect_to :back
  end
  
  def move_up
    @forum.move_higher
    
    redirect_to :back
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
