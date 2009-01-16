class CreateContent < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.references :groupable, :polymorphic => true, :null => false
      t.references :article_type
      t.string :title, :null => false
      t.text :body, :null => false
      t.references :locale
      t.timestamps
    end
    
    create_table :article_types do |t|
      t.string :key, :null => false
      t.string :name, :null => false
    end

    create_table :content_types do |t|
      t.string :key, :null => false
      t.string :name, :null => false
      t.string :mime, :null => false
      t.string :extension, :null => false
    end

    create_table :languages do |t|
      t.string :code, :null => false
    end
    
    create_table :locales do |t|
      t.references :language, :null => false
      t.references :country, :null => false
    end
        
    create_table :medias do |t|
      t.references :groupable, :polymorphic => true, :null => false
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
    
    create_table :pages do |t|
      t.string :name, :null => false
      t.string :permalink
      t.references :group, :null => false
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
      t.timestamps
    end
    
    create_table :themeables_themes do |t|
      t.references :themeable, :polymorphic => true, :null => false
      t.references :theme, :null => false
    end
    
    add_index :themeables_themes, [ :themeable_id, :themeable_type ], :unique => true
  end

  def self.down
    drop_table :articles
    drop_table :article_types
    drop_table :content_types
    drop_table :languages
    drop_table :locales
    drop_table :medias
    drop_table :pages
    drop_table :themes
    drop_table :themeables_themes
  end
end
