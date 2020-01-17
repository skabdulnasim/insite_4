class CreateItemPreferences < ActiveRecord::Migration
  def change
    create_table :item_preferences do |t|
      t.text :preference

      t.timestamps
    end
  end
end
