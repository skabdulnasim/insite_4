class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :media_file_name
      t.string :media_content_type
      t.string :media_file_size
      t.datetime :media_updated_at
      t.integer :asset_id
      t.string :asset_type
      t.text :properties
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
