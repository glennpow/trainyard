class Post < ActiveRecord::Base
  belongs_to :user, :counter_cache => true
  belongs_to :topic, :counter_cache => true
  has_one :forum, :through => :topic
  
  before_save { |post| post.body.strip! }
  after_create :increment_counts
  after_save :update_guru_points
  after_destroy :decrement_counts

  validates_presence_of :topic, :user, :body
  
  searches_on :body
  
  def first?
    return @first if defined?(@first)
    @first = self == self.topic.posts.first
  end
  
  def topic_name
    @topic_name ||= self.first? ? self.topic.name : I18n.t(:regarding_topic, :scope => [ :content ], :topic => self.topic.name)
  end
  
  def quote_from(post)
    (self.body ||= "") << "\n\n\n" +
      I18n.t(:quoted_from_post, :scope => [ :content ], :post => "#{post.user.name} (#{post.created_at.to_s(:long)})") + "\n\n" +
      post.body.gsub(/^/, "> ")
  end
  
  def may_edit_guru_points?(user)
    self.guru_points == 0 && self.topic.guru_points_available > 0 && !user.is_editor_of?(self) && user.is_editor_of?(self.topic)
  end
  
  
  private
  
  def increment_counts
    Topic.update_all([ 'replied_at = ?', Time.now.utc ], [ 'id = ?', self.topic_id ])
    Forum.increment_counter(:posts_count, self.forum.id)
  end
  
  def update_guru_points
    self.user.update_attribute(:guru_points, self.user.posts.map(&:guru_points).sum) unless self.guru_points.zero?
  end
  
  def decrement_counts
    Forum.decrement_counter(:posts_count, self.forum.id)
  end
end
