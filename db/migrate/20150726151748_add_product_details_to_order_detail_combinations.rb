class AddProductDetailsToOrderDetailCombinations < ActiveRecord::Migration
  def change
    add_column :order_detail_combinations, :product_id, :integer
    add_column :order_detail_combinations, :product_name, :string
    add_column :order_detail_combinations, :product_price, :float
  end
end
