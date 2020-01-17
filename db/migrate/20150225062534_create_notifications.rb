class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :title, :null => false, :limit => 30
      t.text :description
      t.text :notification_type, :limit => 25
      t.string :target_url
      t.integer :unit_id, :null => false
      t.boolean :viewed, :default => false
      t.text :json_data

      t.timestamps
    end
    add_index("notifications", "unit_id")
  end
end
