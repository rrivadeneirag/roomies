class SwitchListingsMedia < ActiveRecord::Migration[8.0]
  def up
    drop_table :photos, if_exists: true
    remove_column :listings, :description, if_exists: true
  end

  def down
    add_column :listings, :description, :text
    create_table :photos do |t|
      t.references :listing, null: false, foreign_key: true
      t.string :image_url, null: false
      t.integer :position, null: false, default: 1
      t.timestamps
    end
  end
end
