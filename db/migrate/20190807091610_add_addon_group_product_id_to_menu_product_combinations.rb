class AddAddonGroupProductIdToMenuProductCombinations < ActiveRecord::Migration
  def change
    add_column :menu_product_combinations, :addons_group_product_id, :integer
  end
end
