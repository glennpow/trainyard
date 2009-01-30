class Forum < ActiveRecord::Base
  acts_as_resource
  acts_as_list

  has_many :topics, :include => :user, :order => 'sticky DESC, replied_at DESC', :dependent => :destroy do
    def first
      @first_topic ||= find(:first, :conditions => [ 'sticky == ?', false ])
    end
  end
  has_many :posts, :include => :user, :order => 'created_at ASC' do
    def last
      @last_post ||= find(:last, :include => :user)
    end
  end
  belongs_to :parent_forum, :class_name => 'Forum'

  validates_presence_of :name
  
  searches_on :name
end
