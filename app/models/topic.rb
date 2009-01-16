class Topic < ActiveRecord::Base
  belongs_to :forum, :counter_cache => true
  belongs_to :user
  has_many :posts, :include => :user, :order => 'created_at ASC', :dependent => :destroy do
    def first
      @first_post ||= find(:first, :include => :user)
    end

    def last
      @last_post ||= find(:last, :include => :user)
    end
  end
  
  validates_presence_of :forum, :user, :name
  
  before_create { |topic| topic.replied_at = Time.now.utc }
  
  searches_on :name

  def author_count
    self.posts.map { |post| post.user_id }.uniq.size
  end
  
  def hit!
    self.class.increment_counter :hits, self.id
  end

  def view_count
    self.hits
  end
  
  def guru_points_available
    self.guru_points - self.posts.map(&:guru_points).sum
  end
  
  def watching_users
    self.posts.map(&:user).uniq
  end
end
