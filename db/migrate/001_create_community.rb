class CreateCommunity < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.references :group, :null => false
      t.string :name, :null => false
      t.timestamps
    end
    
    create_table :comments do |t|
      t.references :commentable, :polymorphic => true
      t.references :user
      t.string :user_name
      t.text :body
      t.timestamps
    end
    
    create_table :forums do |t|
      t.string :name
      t.text :description
      t.integer :topics_count, :default => 0
      t.integer :posts_count, :default => 0
      t.integer :position
      t.timestamps
    end

    create_table :forums_users do |t|
      t.references :forum
      t.references :user
    end

    add_index :forums_users, [ :forum_id ]
    add_index :forums_users, [ :user_id ]

    create_table :groups do |t|
      t.string :name, :null => false
      t.references :moderator, :null => false
      t.references :parent_group
      t.timestamps
    end

    create_table :groups_users, :id => false do |t|
      t.references :group, :null => false
      t.references :user, :null => false
    end
    
    add_index :groups_users, :group_id
    add_index :groups_users, :user_id

    create_table :invites do |t|
      t.references :group, :null => false
      t.string :email, :null => false
      t.string :invite_code, :limit => 40
      t.boolean :moderator, :default => false
      t.timestamps
    end

    create_table :messages do |t|
      t.references :from_user, :null => false
      t.references :to_user, :null => false
      t.string :subject, :null => false
      t.text :body
      t.boolean :read, :default => false
      t.timestamps
    end

    create_table :posts do |t|
      t.references :user
      t.references :topic
      t.text :body
      t.integer :guru_points, :default => 0
      t.timestamps
    end

    add_index :posts, [ :topic_id ]
    add_index :posts, [ :user_id ]

    create_table :reviews do |t|
      t.references :reviewable, :polymorphic => true
      t.references :user, :null => false
      t.text :body
      t.integer :rating
      t.timestamps
    end

    create_table :roles do |t|
      t.string :key, :null => false
      t.string :name, :null => false
    end

    create_table :roles_users, :id => false do |t|
      t.references :role, :null => false
      t.references :user, :null => false
    end
    
    add_index :roles_users, :role_id
    add_index :roles_users, :user_id

    create_table :topics do |t|
      t.references :forum
      t.references :user
      t.string :name
      t.integer :hits, :default => 0
      t.boolean :sticky, :default => false
      t.integer :guru_points, :default => 0
      t.integer :posts_count, :default => 0
      t.datetime :replied_at
      t.timestamps
    end

    add_index :topics, [ :forum_id ]
    add_index :topics, [ :user_id ]

    create_table :users do |t|
      t.string :login, :limit => 40, :null => false
      t.string :name, :limit => 100, :default => '', :null => true
      t.string :email, :limit => 100, :null => false
      t.string :crypted_password, :null => false
      t.string :password_salt, :null => false
      t.string :persistence_token
      t.string :perishable_token
      t.datetime :current_login_at
      t.boolean :confirmed, :default => false
      t.boolean :active, :default => true
      t.references :locale
      t.string :time_zone
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.integer :posts_count, :default => 0
      t.integer :guru_points, :default => 0
      t.timestamps
    end
    
    add_index :users, :login, :unique => true
    add_index :users, :email
    add_index :users, :persistence_token
    add_index :users, :perishable_token

    create_table :user_configs do |t|
      t.references :user, :null => false
      t.boolean :mailer_alerts, :default => true
      t.boolean :visible_contact, :default => false
    end
  end

  def self.down
    drop_table :blogs
    drop_table :comments
    drop_table :forums
    drop_table :forums_users
    drop_table :groups
    drop_table :group_users
    drop_table :invites
    drop_table :messages
    drop_table :posts
    drop_table :reviews
    drop_table :roles
    drop_table :roles_users
    drop_table :topics
    drop_table :users
    drop_table :user_configs
  end
end
