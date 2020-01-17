class AddAmmountDetailsToMenuProductCombinations < ActiveRecord::Migration
  def change
    add_column :menu_product_combinations, :ammount, :float, :default => 0
    add_column :menu_product_combinations, :product_unit_id, :integer
  end
end
