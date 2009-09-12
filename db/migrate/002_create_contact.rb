class CreateContact < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.string :street_1, :null => false
      t.string :street_2
      t.string :city, :null => false
      t.references :region, :null => false
      t.string :postal_code, :null => false
      t.references :country, :null => false
      t.string :address_type
      t.float :latitude
      t.float :longitude
      t.timestamps
    end
    
    add_index :addresses, [ :resource_type, :resource_id ]
    
    create_table :countries do |t|
      t.string :name, :null => false
      t.string :official_name
      t.string :alpha_2_code, :null => false
      t.string :alpha_3_code, :null => false
      t.integer :numeric_3_code
      t.timestamps
    end
    
    add_index :countries, :alpha_2_code
    add_index :countries, :alpha_3_code
    add_index :countries, :numeric_3_code

    create_table :emails do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.string :email_address, :null => false
      t.string :email_type
      t.timestamps
    end
    
    add_index :emails, [ :resource_type, :resource_id ]

    create_table :personas do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :prefix
      t.string :suffix
      t.string :gender
      t.date :birthdate
      t.timestamps
    end
    
    add_index :personas, [ :resource_type, :resource_id ]
    
    create_table :phones do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.string :number, :null => false
      t.string :extension
      t.string :phone_type
      t.timestamps
    end
    
    add_index :phones, [ :resource_type, :resource_id ]

    create_table :regions do |t|
      t.references :country, :null => false
      t.string :name, :null => false
      t.string :alpha_code, :null => false
      t.integer :numeric_code, :null => false
      t.timestamps
    end
    
    add_index :regions, :country_id
    add_index :regions, :alpha_code
    add_index :regions, :numeric_code
    
    create_table :urls do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.string :url_address, :null => false
      t.string :url_type
      t.timestamps
    end
    
    add_index :urls, [ :resource_type, :resource_id ]
  end

  def self.down
    drop_table :addresses
    drop_table :countries
    drop_table :emails
    drop_table :personas
    drop_table :phones
    drop_table :regions
    drop_table :urls
  end
end
