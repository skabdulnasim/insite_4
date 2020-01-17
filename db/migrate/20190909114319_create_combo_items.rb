class CreateComboItems < ActiveRecord::Migration
  def change
    create_table :combo_items do |t|
      t.integer :menu_product_id
      t.integer :item_id
      t.integer :tax_group_id
      t.float :sell_price
      t.float :sell_price_without_tax
      t.integer :mode
      t.integer :size_id
      t.integer :color_id

      t.timestamps
    end
  end
end
