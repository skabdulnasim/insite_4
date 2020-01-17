class AddPriceAndAmmountAndProductUnitIdToAddonsGroupProducts < ActiveRecord::Migration
  def change
    add_column :addons_group_products, :price, :integer
    add_column :addons_group_products, :ammount, :integer
    add_column :addons_group_products, :product_unit_id, :integer
  end
end
