class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :icon
      t.string :color
      t.string :tag_type
      t.string :status

      t.timestamps
    end
  end
end
