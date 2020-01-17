class CreateDeveloperApps < ActiveRecord::Migration
  def change
    create_table :developer_apps do |t|
      t.string :name
      t.text :description
      t.text :app_secret
      t.boolean :is_active
      t.text :website

      t.timestamps
    end
  end
end
