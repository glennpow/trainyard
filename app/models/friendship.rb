class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"
  has_enumeration :friendship_type

  validates_presence_of :user, :friend, :friendship_type
  
  before_destroy :destroy_pending
  
  def accept
    !Friendship.accept(user, friend).nil?
  end
  
  def breakup
    Friendship.breakup(user, friend)
  end
  
  def self.find_between(user, friend)
    find_by_user_id_and_friend_id(user, friend)
  end

  def self.exists?(user, friend, friendship_type = nil)
    friendship = find_between(user, friend)
    unless friendship.nil?
      friendship_type.nil? || friendship.friendship_type == friendship_type
    else
      false
    end
  end
  class << self
    alias_method :exist?, :exists?
  end
  
  def self.requested?(user, friend)
    exists?(user, friend, FriendshipType[:requested])
  end
  
  def self.pending?(user, friend)
    exists?(user, friend, FriendshipType[:pending])
  end
  
  def self.accepted?(user, friend)
    exists?(user, friend, FriendshipType[:accepted])
  end

  def self.request(user, friend)
    return nil if user == friend
    
    transaction do
      if (friendship = find_between(user, friend)).nil?
        friendship = create!(:user => user, :friend => friend, :friendship_type => FriendshipType[:pending])
        Activity.track!(:user => user, :public => true, :resource => friend, :message => I18n.t(:friendship_requested_of_user, :scope => [ :social ], :user => h(friendship.friend.name)))
      elsif friendship.friendship_type == FriendshipType[:requested]
        return accept(user, friend)
      end
      
      if (inverse_friendship = find_between(friend, user)).nil?
        inverse_friendship = create!(:user => friend, :friend => user, :friendship_type => FriendshipType[:requested])
        Activity.track!(:user => friend, :public => true, :resource => user, :message => I18n.t(:friendship_requested_from_user, :scope => [ :social ], :user => h(friendship.user.name)),
          :mail => { :subject => I18n.t(:email_subject, :scope => [ :social, :friendship_request ], :user => h(friendship.user.name)),
            :body => Proc.new { |template| template.auto_format(I18n.t(:email_body, :scope => [ :social, :friendship_request ], :user => h(friendship.user.name),
              :url => template.url_for(:controller => 'friendships', :action => 'index', :only_path => false))) }
          }
        )
      elsif inverse_friendship.friendship_type != FriendshipType[:requested]
        return accept(user, friend)
      end
      
      return friendship
    end
  rescue Exception => e
    logger.error(e)
    nil
  end

  def self.accept(user, friend)
    return nil if user == friend
    
    transaction do
      if (friendship = find_between(user, friend)).nil?
        friendship = create!(:user => user, :friend => friend, :friendship_type => FriendshipType[:accepted])
      elsif friendship.friendship_type != FriendshipType[:accepted]
        friendship.update_attributes!(:friendship_type => FriendshipType[:accepted])
        Activity.track!(:user => user, :public => true, :resource => friend, :message => I18n.t(:friendship_accepted_for_user, :scope => [ :social ], :user => h(friendship.friend.name)))
      end
      
      if (inverse_friendship = find_between(friend, user)).nil?
        inverse_friendship = create!(:user => friend, :friend => user, :friendship_type => FriendshipType[:requested])
      elsif inverse_friendship.friendship_type != FriendshipType[:accepted]
        inverse_friendship.update_attributes!(:friendship_type => FriendshipType[:accepted])
        Activity.track!(:user => friend, :public => true, :resource => user, :message => I18n.t(:friendship_accepted_for_user, :scope => [ :social ], :user => h(friendship.user.name)))
      end

      return friendship
    end
  rescue Exception => e
    logger.error(e)
    nil
  end

  def self.breakup(user, friend)
    transaction do
      destroy(find_between(user, friend))
      destroy(find_between(friend, user))
    end
    
    true
  rescue Exception => e
    logger.error(e)
    false
  end
  
  
  private
  
  def destroy_pending
    friendship = Friendship.find_between(friend, user)
    Friendship.destroy(friendship) if friendship.try(:friendship_type) == FriendshipType[:pending]
  end
end