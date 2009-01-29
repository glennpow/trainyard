class CreateContact < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.references :contact, :null => false
      t.string :street_1, :null => false
      t.string :street_2
      t.string :city, :null => false
      t.references :region, :null => false
      t.string :postal_code, :null => false
      t.references :country, :null => false
      t.references :address_type
      t.float :latitude
      t.float :longitude
      t.timestamps
    end

    create_table :contacts do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.references :prefix
      t.references :suffix
      t.references :gender
      t.date :birthdate
      t.references :resource, :polymorphic => true
      t.timestamps
    end
    
    create_table :countries do |t|
      t.string :name, :null => false
      t.string :official_name
      t.string :alpha_2_code, :null => false
      t.string :alpha_3_code, :null => false
      t.integer :numeric_3_code
      t.timestamps
    end

    create_table :emails do |t|
      t.string :email_address, :null => false
      t.references :email_type
      t.references :resource, :polymorphic => true
      t.timestamps
    end
    
    create_table :phones do |t|
      t.string :number, :null => false
      t.string :extension
      t.references :phone_type
      t.references :resource, :polymorphic => true
      t.timestamps
    end

    create_table :regions do |t|
      t.references :country, :null => false
      t.string :name, :null => false
      t.string :alpha_code, :null => false
      t.integer :numeric_code, :null => false
      t.timestamps
    end
    
    create_table :urls do |t|
      t.string :url_address, :null => false
      t.references :url_type
      t.references :resource, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
    drop_table :contacts
    drop_table :countries
    drop_table :emails
    drop_table :phones
    drop_table :regions
    drop_table :urls
  end
end
