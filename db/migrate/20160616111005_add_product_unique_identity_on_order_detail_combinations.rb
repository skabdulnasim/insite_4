class AddProductUniqueIdentityOnOrderDetailCombinations < ActiveRecord::Migration
  def change
    add_column :order_detail_combinations, :product_unique_identity, :string
  end
end
