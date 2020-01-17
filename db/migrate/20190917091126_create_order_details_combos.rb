class CreateOrderDetailsCombos < ActiveRecord::Migration
  def change
    create_table :order_details_combos do |t|
      t.integer :order_detail_id
      t.integer :combo_item_id
      t.float :unit_price_without_tax
      t.float :unit_price_with_tax
      t.text :tax_details
      t.integer :product_id
      t.string :product_name
      t.float :tax_amount
      t.float :subtotal
      t.string :is_stock_debited
      t.integer :size_id
      t.integer :color_id
      t.float :quantity
      t.integer :lot_id
      t.string :product_unique_identity

      t.timestamps
    end
  end
end
