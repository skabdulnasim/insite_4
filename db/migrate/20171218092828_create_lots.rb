class CreateLots < ActiveRecord::Migration
  def change
    create_table :lots do |t|
      t.integer :menu_product_id
      t.text :sku
      t.integer :mode
      t.float :sell_price
      t.float :stock_qty
      t.float :sell_price_without_tax
      t.integer :tax_group_id
      t.integer :mode
      t.integer :product_id
      
      t.timestamps
    end
  end
end
