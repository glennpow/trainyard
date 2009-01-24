class CreateContent < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.references :group
      t.references :user, :null => false
      t.string :name, :null => false
      t.text :body, :null => false
      t.references :locale
      t.boolean :commentable, :default => true
      t.boolean :reviewable, :default => true
      t.boolean :erased, :default => false
      t.boolean :revisionable, :default => false
      t.integer :revision, :default => 1
      t.timestamps
    end
      
    create_table :article_revisions do |t|
      t.references :article, :null => false
      t.references :user, :null => false
      t.string :name, :null => false
      t.text :body
      t.boolean :erased, :default => false
      t.integer :revision
      t.datetime :created_at
    end

    create_table :blogs do |t|
      t.references :group, :null => false
      t.string :name, :null => false
      t.timestamps
    end
    
    create_table :comments do |t|
      t.references :resource, :polymorphic => true
      t.references :user
      t.string :user_name
      t.text :body
      t.timestamps
    end
    
    create_table :forums do |t|
      t.references :group, :null => false
      t.string :name, :null => false
      t.text :description
      t.integer :topics_count, :default => 0
      t.integer :posts_count, :default => 0
      t.integer :position
      t.references :parent_forum
      t.timestamps
    end

    create_table :languages do |t|
      t.string :code, :null => false
    end
    
    create_table :locales do |t|
      t.references :language, :null => false
      t.references :country, :null => false
    end
        
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
      t.references :content_type
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

    create_table :pages do |t|
      t.string :name, :null => false
      t.string :permalink, :null => false
      t.timestamps
    end

    create_table :posts do |t|
      t.references :user, :null => false
      t.references :topic, :null => false
      t.text :body, :null => false
      t.integer :guru_points, :default => 0
      t.timestamps
    end

    add_index :posts, [ :topic_id ]
    add_index :posts, [ :user_id ]

    create_table :reviews do |t|
      t.references :resource, :polymorphic => true
      t.references :user, :null => false
      t.text :body
      t.integer :rating
      t.timestamps
    end
    
    create_table :themes do |t|
      t.string :name, :null => false
      t.string :body_color
      t.string :body_url
      t.string :base_color
      t.string :base_url
      t.string :base_font_color
      t.string :base_link_color
      t.string :base_link_hover_color
      t.string :primary_color
      t.string :primary_url
      t.string :primary_font_color
      t.string :primary_link_color
      t.string :primary_link_hover_color
      t.string :secondary_color
      t.string :secondary_url
      t.string :secondary_font_color
      t.string :secondary_link_color
      t.string :secondary_link_hover_color
      t.string :highlight_color
      t.string :highlight_url
      t.string :highlight_font_color
      t.string :highlight_link_color
      t.string :highlight_link_hover_color
      t.timestamps
    end
    
    create_table :themeables_themes do |t|
      t.references :themeable, :polymorphic => true, :null => false
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

    add_index :topics, [ :forum_id ]
    add_index :topics, [ :user_id ]
    
    create_table :wikis do |t|
      t.references :group, :null => false
      t.string :name, :null => false
      t.timestamps
    end
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
    drop_table :wikis
  end
end
