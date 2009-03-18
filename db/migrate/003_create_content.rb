class CreateContent < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.references :group
      t.string :article_type
      t.references :user, :null => false
      t.string :name, :null => false
      t.text :body, :null => false
      t.references :locale
      t.boolean :heirarchical, :default => false
      t.boolean :commentable, :default => true
      t.boolean :reviewable, :default => true
      t.boolean :erased, :default => false
      t.boolean :revisionable, :default => false
      t.integer :revision, :default => 1
      t.timestamps
    end
          
    add_index :articles, [ :resource_type, :resource_id, :locale_id ]
    add_index :articles, :group_id
    add_index :articles, :user_id

    create_table :article_revisions do |t|
      t.references :article, :null => false
      t.string :article_type
      t.references :user, :null => false
      t.string :name, :null => false
      t.text :body
      t.boolean :erased, :default => false
      t.integer :revision
      t.datetime :created_at
    end
    
    add_index :article_revisions, :article_id
    add_index :article_revisions, :user_id

    create_table :blogs do |t|
      t.references :group
      t.string :name, :null => false
      t.timestamps
    end
    
    add_index :blogs, :group_id
    
    create_table :comments do |t|
      t.references :resource, :polymorphic => true
      t.references :user
      t.string :user_name
      t.text :body
      t.timestamps
    end
    
    add_index :comments, [ :resource_type, :resource_id ]
    add_index :comments, :user_id
    
    create_table :forums do |t|
      t.references :group
      t.references :parent_forum
      t.string :name, :null => false
      t.text :description
      t.integer :topics_count, :default => 0
      t.integer :posts_count, :default => 0
      t.integer :position
      t.timestamps
    end
    
    add_index :forums, :group_id
    add_index :forums, :parent_forum_id

    create_table :languages do |t|
      t.string :code, :null => false
    end
    add_index :languages, :code
    
    create_table :locales do |t|
      t.references :language, :null => false
      t.references :country, :null => false
    end
    
    add_index :locales, [ :language_id, :country_id ]
        
    create_table :medias do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.string :name, :null => false
      t.string :url
      t.string :media_file_name
      t.string :media_content_type
      t.integer :media_file_size
      t.datetime :media_updated_at
      t.string :thumbnail_file_name
      t.string :thumbnail_content_type
      t.integer :thumbnail_file_size
      t.datetime :thumbnail_updated_at
      t.integer :width
      t.integer :height
      t.string :content_type
      t.timestamps
    end
    
    add_index :medias, [ :resource_type, :resource_id ]
    
    create_table :messages do |t|
      t.references :from_user, :null => false
      t.references :to_user, :null => false
      t.string :subject, :null => false
      t.text :body
      t.boolean :read, :default => false
      t.timestamps
    end

    add_index :messages, :from_user_id
    add_index :messages, :to_user_id

    create_table :pages do |t|
      t.references :group
      t.string :name, :null => false
      t.string :permalink, :null => false
      t.timestamps
    end

    add_index :pages, :group_id
    add_index :pages, :permalink

    create_table :posts do |t|
      t.references :user, :null => false
      t.references :topic, :null => false
      t.text :body, :null => false
      t.integer :guru_points, :default => 0
      t.timestamps
    end

    add_index :posts, :topic_id
    add_index :posts, :user_id

    create_table :reviews do |t|
      t.references :resource, :polymorphic => true
      t.references :user, :null => false
      t.text :body
      t.integer :rating
      t.timestamps
    end
    
    add_index :reviews, [ :resource_type, :resource_id ]
    add_index :reviews, :user_id
    
    create_table :themes do |t|
      t.string :name, :null => false
      t.string :body_color
      t.string :body_background
      t.string :base_color
      t.string :base_background
      t.string :base_font_color
      t.string :base_link_color
      t.string :base_link_hover_color
      t.string :primary_color
      t.string :primary_background
      t.string :primary_font_color
      t.string :primary_link_color
      t.string :primary_link_hover_color
      t.string :secondary_color
      t.string :secondary_background
      t.string :secondary_font_color
      t.string :secondary_link_color
      t.string :secondary_link_hover_color
      t.string :highlight_color
      t.string :highlight_background
      t.string :highlight_font_color
      t.string :highlight_link_color
      t.string :highlight_link_hover_color
      t.timestamps
    end
    
    add_index :themes, :name

    create_table :themeables_themes do |t|
      t.references :themeable, :polymorphic => true
      t.references :theme, :null => false
    end
    
    add_index :themeables_themes, [ :themeable_id, :themeable_type ], :unique => true

    create_table :topics do |t|
      t.references :forum, :null => false
      t.references :user, :null => false
      t.string :name, :null => false
      t.integer :hits, :default => 0
      t.boolean :sticky, :default => false
      t.integer :guru_points, :default => 0
      t.integer :posts_count, :default => 0
      t.datetime :replied_at
      t.timestamps
    end

    add_index :topics, :forum_id
    add_index :topics, :user_id
    
    create_table :watchings do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.references :user, :null => false
      t.timestamps
    end

    add_index :watchings, [ :resource_type, :resource_id ]
    add_index :watchings, :user_id
    
    create_table :wikis do |t|
      t.references :group
      t.string :name, :null => false
      t.timestamps
    end

    add_index :wikis, :group_id
  end

  def self.down
    drop_table :articles
    drop_table :article_revisions
    drop_table :blogs
    drop_table :comments
    drop_table :forums
    drop_table :forums_users
    drop_table :languages
    drop_table :locales
    drop_table :medias
    drop_table :messages
    drop_table :pages
    drop_table :posts
    drop_table :reviews
    drop_table :themes
    drop_table :themeables_themes
    drop_table :topics
    drop_table :watchings
    drop_table :wikis
  end
end
