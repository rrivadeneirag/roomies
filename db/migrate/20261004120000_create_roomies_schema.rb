class CreateRoomiesSchema < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "member"
      t.string :phone
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :neighborhoods do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.timestamps
    end
    add_index :neighborhoods, :name, unique: true

    create_table :amenities do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :amenities, :name, unique: true

    create_table :properties do |t|
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.references :neighborhood, null: false, foreign_key: true
      t.string :address, null: false
      t.string :property_type, null: false
      t.integer :bedrooms, null: false
      t.integer :bathrooms, null: false
      t.text :shared_spaces
      t.timestamps
    end

    create_table :property_amenities do |t|
      t.references :property, null: false, foreign_key: true
      t.references :amenity, null: false, foreign_key: true
      t.timestamps
    end
    add_index :property_amenities, [:property_id, :amenity_id], unique: true

    create_table :listings do |t|
      t.references :property, null: false, foreign_key: true
      t.decimal :monthly_rent, precision: 10, scale: 2, null: false
      t.decimal :deposit, precision: 10, scale: 2, null: false
      t.date :available_on, null: false
      t.integer :minimum_stay_months, null: false
      t.boolean :furnished, null: false, default: false
      t.boolean :private_bathroom, null: false, default: false
      t.text :description
      t.string :status, null: false, default: "Draft"
      t.timestamps
    end
    add_index :listings, :status

    create_table :photos do |t|
      t.references :listing, null: false, foreign_key: true
      t.string :image_url, null: false
      t.integer :position, null: false, default: 1
      t.timestamps
    end

    create_table :applications do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :seeker, null: false, foreign_key: { to_table: :users }
      t.text :message, null: false
      t.date :move_in_on, null: false
      t.integer :stay_months, null: false
      t.string :status, null: false, default: "Pending"
      t.timestamps
    end
    add_index :applications, [:listing_id, :seeker_id], unique: true

    create_table :visits do |t|
      t.references :application, null: false, foreign_key: true
      t.datetime :scheduled_at, null: false
      t.string :status, null: false, default: "Proposed"
      t.timestamps
    end

    create_table :reviews do |t|
      t.references :visit, null: false, foreign_key: true, index: { unique: true }
      t.integer :rating, null: false
      t.text :comment, null: false
      t.boolean :matched, null: false, default: false
      t.date :reviewed_on, null: false
      t.timestamps
    end

    create_table :reports do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.text :reason, null: false
      t.string :status, null: false, default: "Pending"
      t.references :moderator, foreign_key: { to_table: :users }
      t.date :resolved_on
      t.timestamps
    end

    create_table :saved_listings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.timestamps
    end
    add_index :saved_listings, [:user_id, :listing_id], unique: true
  end
end
