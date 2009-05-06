class CreateSocial < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.references :user, :null => false
      t.references :resource, :polymorphic => true, :null => false
      t.string :message
      t.boolean :public, :default => false
      t.timestamps
    end
    
    add_index :activities, [ :user_id, :public ], :name => :index_activity_user
    add_index :activities, [ :resource_type, :resource_id, :public ], :name => :index_activity_resource
    
    create_table :friendships do |t|
      t.references :user, :null => false
      t.references :friend, :null => false
      t.string :friendship_type, :null => false
      t.timestamps
    end
    
    add_index :friendships, [ :user_id, :friend_id ], :name => :index_friendship, :unique => true
    add_index :friendships, [ :user_id, :friendship_type ], :name => :index_friendship_user
    add_index :friendships, [ :friend_id, :friendship_type ], :name => :index_friendship_friend
  end

  def self.down
    drop_table :activities
    drop_table :friendships
  end
end
