class CreateMenuProducts < ActiveRecord::Migration
  def change
    create_table :menu_products do |t|
      t.integer :product_id
      t.integer :menu_category_id
      t.integer :menu_card_id

      t.timestamps
    end
  end
end
