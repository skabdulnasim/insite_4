class AddAddonGroupIdToMenuProductCombinations < ActiveRecord::Migration
  def change
    add_column :menu_product_combinations, :addons_group_id, :integer
  end
end
