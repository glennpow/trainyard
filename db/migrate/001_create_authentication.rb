class CreateAuthentication < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name, :null => false
      t.references :parent_group
      t.timestamps
    end

    create_table :invites do |t|
      t.references :group, :null => false
      t.references :inviter, :null => false
      t.string :email, :null => false
      t.string :invite_code, :limit => 40
      t.timestamps
    end
    
    add_index :invites, :group_id
    add_index :invites, :invite_code

    create_table :memberships do |t|
      t.references :group
      t.references :role, :null => false
      t.references :user, :null => false
      t.timestamps
    end
    
    add_index :memberships, :user_id
    add_index :memberships, [ :group_id, :user_id ]
    add_index :memberships, [ :group_id, :user_id, :role_id ], :unique => true
    
    create_table :organizations do |t|
      t.references :group, :null => false
      t.string :name, :null => false
      t.text :description
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
    
    add_index :organizations, :group_id

    create_table :permissions do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.references :action, :null => false
      t.references :group, :null => false
      t.references :role
    end

    add_index :permissions, [ :group_id, :role_id, :action_id, :resource_id, :resource_type ], :name => :index_permission, :unique => true

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
      t.boolean :mailer_alerts, :default => true
      t.boolean :public_contact, :default => false
      t.timestamps
    end
    
    add_index :users, :login, :unique => true
    add_index :users, :email
    add_index :users, :persistence_token
    add_index :users, :perishable_token
  end

  def self.down
    drop_table :groups
    drop_table :invites
    drop_table :memberships
    drop_table :organizations
    drop_table :permissions
    drop_table :users
  end
end
