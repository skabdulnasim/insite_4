class CreateOrderDetailCombinations < ActiveRecord::Migration
  def change
    create_table :order_detail_combinations do |t|
      t.integer :order_detail_id
      t.integer :menu_product_combination_id
      t.integer :combination_qty
      t.float :total_price

      t.timestamps
    end
  end
end
