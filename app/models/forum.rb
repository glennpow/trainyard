class Forum < ActiveRecord::Base
  acts_as_list

  has_and_belongs_to_many :moderators, :join_table => 'forums_users', :class_name => 'User', :order => 'name ASC'
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

  validates_presence_of :name
end
